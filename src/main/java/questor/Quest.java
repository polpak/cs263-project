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
	
	/*
	 * Exception used for data validation
	 */
	public class ValueError extends Exception {

		public ValueError(String string) {
			super(string);
		}

		/**
		 * 
		 */
		private static final long serialVersionUID = 8181120157863862073L;
	}
	
	/*
	 * Returns a list of quests from the datastore given a list of their keys
	 * 
	 * @param 	questKeys	the list of quest keys to retrieve
	 */
	public static List<Quest> fromKeys(List<Key> questKeys) throws ValueError {

		List<Entity> ents = new ArrayList<Entity>(GAEDatastore.get(questKeys).values());
		List<Quest> quests = new ArrayList<Quest>();
		for(Entity q_ent : ents) {
			quests.add(Quest.fromEntity(q_ent));
		}
		
		return quests;
	}
	
	/*
	 * Fetches a single quest from the datastore by its key
	 * 
	 * @param	questKey	the key for the quest to return
	 */
	public static Quest fromKey(Long questKey) throws EntityNotFoundException, ValueError {
		return Quest.fromEntity(GAEDatastore.get(KeyFactory.createKey("Quest", questKey.longValue())));
	}
	
	
	/*
	 * Fetches a list of quests from the datastore which have been accepted by the quester
	 * 
	 * @param	quester		the user which accepted the quests
	 */
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
	
	/*
	 * Fetches a list of quests from the datastore which have been posted by the given questMaster
	 * 
	 * @param 	questMaster		the user which posted the quests
	 */
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
	
	/*
	 * Fetches a list of quests from the datastore which the user may be able to accept.
	 * This list will not include any quests posted by the given user
	 * 
	 * @param 	questor		the user looking for a quest
	 */
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

	/*
	 * The public constructor for a quest. Raises ValueError if the fields aren't acceptable.
	 * This constructor will automatically add the quest to the datastore. The quest expiration date will
	 * be auto-filled to 2 days from the current date.
	 * 
	 * @param	questMaster		the user posting the quest
	 * @param	title			the quest title
	 * @param 	description		the quest description
	 * @param	reward			the quest reward
	 */
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


	/*
	 * Getter for the questerKey field
	 */
	public String getQuesterKey() {
		return questerKey;
	}
	
	/*
	 * Getter for the completed field
	 */
	public boolean isCompleted() {
		return completed;
	}
	
	
	/*
	 * Helper method to determine if the quest is accepted
	 */
	public boolean isAccepted() {
		return (this.questerKey != null);
	}
	
	/*
	 * Setter for the questerKey field
	 */
	public void setQuesterKey(String questerKey) {
		this.questerKey = questerKey;
	}

	/*
	 * Setter for the completed field
	 */
	public void setCompleted(boolean completed) {
		this.completed = completed;
	}
	
	/*
	 * Getter for the questMasterKey field
	 */
	public String getQuestMasterKey() {
		return questMasterKey;
	}

	/*
	 * Getter for the title field
	 */
	public String getTitle() {
		return title;
	}
	

	/*
	 * Setter for the title field
	 */
	public void setTitle(String title) throws ValueError {
		
		if(title == null || title.trim().isEmpty())
			throw new ValueError("Quests must have a valid title.");
		
		this.title = title;
	}
	
	/*
	 * Getter for the description field
	 */
	public String getDescription() throws ValueError {
		
		if(description == null || description.trim().isEmpty())
			throw new ValueError("Quests must have a valid description.");
		
		return description;
	}
	
	/*
	 * Setter for the description field
	 */
	public void setDescription(String description) {
		this.description = description;
	}
	
	/*
	 * Getter for the expiration field
	 */
	public Date getExpiration() {
		return expiration;
	}
	
	
	/*
	 * Setter for the expiration field
	 */
	public void setExpiration(Date expiration) throws ValueError {
		
		this.expiration = expiration;
	}

	/*
	 * Getter for the reward field
	 */
	public long getReward() {
		return reward;
	}

	/*
	 * Setter for the reward field
	 */
	public void setReward(long value) throws ValueError {
		
		if(value <= 0)
			throw new ValueError("Quests must have a positive reward.");
		
		this.reward = value;
	}

	/*
	 * Getter for the questKey field
	 */
	public Long getQuestKey() {
		return questKey;
	}

	/*
	 * Setter for the questKey field
	 */
	public void setQuestKey(Long value) {
		this.questKey = value;
	}

	/*
	 * Construct a quest from a json string. Note that this newly created
	 * quest will not be stored in the datastore.
	 * 
	 * @param 	json	the json representation of the quest
	 */
	public static Quest fromJSON(String json) throws ValueError {
		Gson gson = new Gson();
		System.out.println(json);
    	Quest q =  gson.fromJson(json, Quest.class);
    	return q;
	}
	
	/*
	 * Convert a quest to a json string.
	 */
	public String toJson() {
		Gson gson = new Gson();
    	String json = gson.toJson(this);
    	return json;
	}
	
	/*
	 * Save a quest to the datastore (updating its properties)
	 */
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
	
	/*
	 * Deletes all quests which have expired
	 */
	public static void expireQuests() {
		
		Query q = new Query("Quest").setFilter(new Query.FilterPredicate("expiration",
				FilterOperator.LESS_THAN_OR_EQUAL,
				(new Date())));
		
		Quest.expireByQuery(q);
		
		q = new Query("Quest").setFilter(new Query.FilterPredicate("completed",
				FilterOperator.EQUAL,
				true));
		
		Quest.expireByQuery(q);
		
	}
	
	private static void expireByQuery(Query q) {
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
