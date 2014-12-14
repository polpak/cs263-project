package questor;

import java.util.ArrayList;
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
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.SortDirection;


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
	
	public static Quest fromKey(String questKey) throws EntityNotFoundException, ValueError {
		return Quest.fromEntity(GAEDatastore.get(KeyFactory.createKey("Quest", questKey)));
	}
	
	public static List<Quest> findByQuester(User quester) {
		Query query = new Query("Quest").setFilter(new Query.FilterPredicate("quester_key",
															FilterOperator.EQUAL,
															quester.getUserKey()
													)).addSort("expires", SortDirection.ASCENDING);
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
													)).addSort("expires", SortDirection.ASCENDING);
		try {
			return Quest.fromEntities(GAEDatastore.prepare(query).asList(FetchOptions.Builder.withDefaults()));
		} catch (ValueError e) {
			return new ArrayList<Quest>();
		}
	}

	public Quest(User questMaster, String title, String description, int reward, Date expiration) 
			throws ValueError {
		
		if(questMaster == null)
			throw new ValueError("Quests must have an valid owner.");
		
		this.questMasterKey = questMaster.getUserKey();
		
		this.setTitle(title);
		this.setDescription(description);
		this.setCompleted(false);
		this.setReward(reward);
		this.setExpires(expiration);
		
		
		Entity e = new Entity("Quest");
		e.setProperty("quest_master_key", this.questMasterKey);
		e.setProperty("title", title);
		e.setProperty("description", description);
		e.setProperty("reward", reward);
		e.setProperty("expires", expiration);

		GAEDatastore.put(e);
		
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
	
	public Date getExpires() {
		return expires;
	}
	
	public void setExpires(Date expiration) throws ValueError {
		if(expiration == null || expiration.before(new Date()))
			throw new ValueError("Quests must have a future date.");
		
		this.expires = expiration;
	}

	
	public Integer getReward() {
		return reward;
	}

	public void setReward(Integer reward) throws ValueError {
		
		if(reward <= 0)
			throw new ValueError("Quests must have a positive reward.");
		
		this.reward = reward;
	}


	public String getQuestKey() {
		return questKey;
	}

	public void setQuestKey(String questKey) {
		this.questKey = questKey;
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
			q.setExpires((Date) entity.getProperty("expires"));
			q.setQuestKey((String) entity.getProperty("quest_key"));
			
			if(entity.hasProperty("quester_key"))
				q.setQuesterKey((String) entity.getProperty("quester_key"));
			
			quests.add(q);
		}
		return quests;
	}

	private static DatastoreService GAEDatastore = DatastoreServiceFactory.getDatastoreService();
	
	private String questKey;
	private String questMasterKey;
	private String title;
	private String description;
	private Date expires;
	private String questerKey;
	private Integer reward;
	private boolean completed;


	
}
