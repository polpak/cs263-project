package questor;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.SortDirection;
import com.google.gson.Gson;


/*
 * The quest model wraps the GAE entities for ease of use in JSP and servlets
 */
public class Quest {
	
	public class ValueError extends Exception {

		public ValueError(String string) {
			super(string);
		}

		/**
		 * 
		 */
		private static final long serialVersionUID = 8181120157863862073L;
	}
	
	public static List<Quest> fromKeys(List<Key> questKeys) throws ValueError {

		List<Entity> ents = new ArrayList<Entity>(GAEDatastore.get(questKeys).values());
		List<Quest> quests = new ArrayList<Quest>();
		for(Entity q_ent : ents) {
			quests.add(Quest.fromEntity(q_ent));
		}
		
		return quests;
	}
	
	
	public static Quest fromKey(Long questKey) throws EntityNotFoundException, ValueError {
		return Quest.fromEntity(GAEDatastore.get(KeyFactory.createKey("Quest", questKey.longValue())));
	}
	
	public static List<Quest> findByQuester(User quester) {
		Query query = new Query("Quest").setFilter(new Query.FilterPredicate("quester_key",
															FilterOperator.EQUAL,
															quester.getUserKey()
													)).addSort("expiration", SortDirection.ASCENDING);
		try {
			return Quest.fromEntities(GAEDatastore.prepare(query).asList(FetchOptions.Builder.withDefaults()));
		} catch (ValueError e) {
			return new ArrayList<Quest>();
		}
	}
	
	public static List<Quest> findByQuestMaster(User questMaster) {
		Query query = new Query("Quest").setFilter(new Query.FilterPredicate("quest_master_key",
															FilterOperator.EQUAL,
															questMaster.getUserKey()
													)).addSort("expiration", SortDirection.ASCENDING);
		try {
			return Quest.fromEntities(GAEDatastore.prepare(query).asList(FetchOptions.Builder.withDefaults()));
		} catch (ValueError e) {
			return new ArrayList<Quest>();
		}
	}
	
	public static List<Quest> getAvailableForUser(User questor) {
		Filter notOwner = new Query.FilterPredicate("quest_master_key",
				FilterOperator.NOT_EQUAL,
				questor.getUserKey()
		);
		
		
		Query query = new Query("Quest").setFilter(notOwner);
		try {
			return Quest.fromEntities(GAEDatastore.prepare(query).asList(FetchOptions.Builder.withDefaults()));
		} catch (ValueError e) {
			return new ArrayList<Quest>();
		}
	}

	public Quest(User questMaster, String title, String description, Long reward) 
			throws ValueError {
		
		if(questMaster == null)
			throw new ValueError("Quests must have an valid owner.");
		
		this.questMasterKey = questMaster.getUserKey();
		
		Calendar c = Calendar.getInstance();
		c.add(Calendar.DATE, 2);
		Date expiration = c.getTime();
		
		
		this.setTitle(title);
		this.setDescription(description);
		this.setCompleted(false);
		this.setReward(reward);
		this.setExpiration(expiration);
		
		
		Entity e = new Entity("Quest");
		e.setProperty("quest_master_key", this.questMasterKey);
		e.setProperty("title", title);
		e.setProperty("description", description);
		e.setProperty("reward", reward);
		e.setProperty("expiration", expiration);
		e.setProperty("completed", completed);

		GAEDatastore.put(e);
		
		e.setProperty("quest_key", e.getKey().getId());
		GAEDatastore.put(e);
		this.setQuestKey(e.getKey().getId());
	}


	public String getQuesterKey() {
		return questerKey;
	}
	
	public boolean isCompleted() {
		return completed;
	}
	
	public boolean isAccepted() {
		return (this.questerKey != null);
	}
	
	public void setQuesterKey(String questerKey) {
		this.questerKey = questerKey;
	}

	public void setCompleted(boolean completed) {
		this.completed = completed;
	}
	
	public String getQuestMasterKey() {
		return questMasterKey;
	}

	public String getTitle() {
		return title;
	}
	public void setTitle(String title) throws ValueError {
		
		if(title == null || title.trim().isEmpty())
			throw new ValueError("Quests must have a valid title.");
		
		this.title = title;
	}
	public String getDescription() throws ValueError {
		
		if(description == null || description.trim().isEmpty())
			throw new ValueError("Quests must have a valid description.");
		
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	
	public Date getExpiration() {
		return expiration;
	}
	
	public void setExpiration(Date expiration) throws ValueError {
		
		this.expiration = expiration;
	}

	
	public long getReward() {
		return reward;
	}

	public void setReward(long value) throws ValueError {
		
		if(value <= 0)
			throw new ValueError("Quests must have a positive reward.");
		
		this.reward = value;
	}


	public Long getQuestKey() {
		return questKey;
	}

	public void setQuestKey(Long value) {
		this.questKey = value;
	}

	public static Quest fromJSON(String json) throws ValueError {
		Gson gson = new Gson();
		System.out.println(json);
    	Quest q =  gson.fromJson(json, Quest.class);
    	return q;
	}
	
	public String toJson() {
		Gson gson = new Gson();
    	String json = gson.toJson(this);
    	return json;
	}
	
	public void updateStore() throws EntityNotFoundException {
		if(this.questKey == null)
			throw new EntityNotFoundException(null);
		
		Entity e = GAEDatastore.get(KeyFactory.createKey("Quest", this.questKey.longValue()));
		
		e.setProperty("quest_master_key", this.questMasterKey);
		e.setProperty("title", title);
		e.setProperty("description", description);
		e.setProperty("reward", reward);
		e.setProperty("expiration", expiration);
		e.setProperty("completed", completed);
		
		if(this.questerKey != null)
			e.setProperty("quester_key", this.questerKey);

		GAEDatastore.put(e);
		
	}
	
	public static void expireQuests() {
		
		Query q = new Query("Quest").setFilter(new Query.FilterPredicate("expiration",
				FilterOperator.LESS_THAN_OR_EQUAL,
				(new Date())));
		
		List<Entity> expiredEntities = GAEDatastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		List<Key> keys = new ArrayList<Key>();
		
		for(Entity e : expiredEntities) {
			System.out.println("Expiring" + e.getKey().toString());
			keys.add(e.getKey());
		}
		
		GAEDatastore.delete(keys);
		
	}
	
	/*
	 * Create an empty quest (internal use only)
	 */
	private Quest() {}
	
	private static Quest fromEntity(Entity entity) throws ValueError {
		List<Entity> list = new ArrayList<Entity>();
		list.add(entity);
		return Quest.fromEntities(list).get(0);
	}
	
	/*
	 * Create a new quest from a list of entities
	 */
	private static List<Quest> fromEntities(List<Entity> entities) throws ValueError {
		List<Quest> quests = new ArrayList<Quest>();
		for(Entity entity: entities) {
			Quest q = new Quest();
			
			q.questMasterKey = (String) entity.getProperty("quest_master_key");
			
			q.setTitle((String) entity.getProperty("title"));
			q.setDescription((String) entity.getProperty("description"));
			q.setExpiration((Date) entity.getProperty("expiration"));
			q.setQuestKey((Long) entity.getProperty("quest_key"));
			q.setReward((Long)entity.getProperty("reward"));
			q.setCompleted((Boolean)entity.getProperty("completed"));
			
			if(entity.hasProperty("quester_key"))
				q.setQuesterKey((String) entity.getProperty("quester_key"));
			
			quests.add(q);
		}
		return quests;
	}

	private static DatastoreService GAEDatastore = DatastoreServiceFactory.getDatastoreService();
	
	private Long questKey;
	private String questMasterKey;
	private String title;
	private String description;
	private Date expiration;
	private String questerKey;
	private long reward;
	private boolean completed;


	
}
