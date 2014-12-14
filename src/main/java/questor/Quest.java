package questor;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;

public class Quest {
	
	public static Quest fromJson(String json) {
		return new Quest();
	}
	
	public static Quest fromDatastore(DatastoreService store, String questKey) 
			throws EntityNotFoundException{
		Entity q = store.get(KeyFactory.createKey("Quest", questKey));
		return Quest.fromEntity(q);
	}
	
	public static List<Quest> fromDatastore(DatastoreService store, List<String> keyStrings) {
		List<Key> keys = new ArrayList<Key>();
		for(String k_string : keyStrings) {
			keys.add(KeyFactory.createKey("Quest", k_string));
		}
		List<Entity> ents = new ArrayList<Entity>(store.get(keys).values());
		List<Quest> quests = new ArrayList<Quest>();
		for(Entity q_ent : ents) {
			quests.add(Quest.fromEntity(q_ent));
		}
		
		return quests;
	}
	
	/*
	 * Create a new quest from an entity
	 */
	public static Quest fromEntity(Entity entity) {
		Quest q = new Quest();
		
		q.setQuestMasterKey((String) entity.getProperty("quest_master_key"));
		q.setTitle((String) entity.getProperty("title"));
		q.setDescription((String) entity.getProperty("description"));
		q.setExpires((Date) entity.getProperty("expires"));
		
		if(entity.hasProperty("quester_key"))
			q.setQuesterKey((String) entity.getProperty("quester_key"));
		
		return q;
	}
	
	public static List<Quest> fromQuery(DatastoreService store, Query q) {
		List<Entity> entities = store.prepare(q).asList(FetchOptions.Builder.withDefaults());
	    
	    List<Quest> quests = new ArrayList<Quest>();
	    
	    for(Entity q_ent : entities) {
	    	quests.add(Quest.fromEntity(q_ent));
	    }
	    return quests;
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
	public void setQuestMasterKey(String questMasterKey) {
		this.questMasterKey = questMasterKey;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public Date getExpires() {
		return expires;
	}
	public void setExpires(Date expires) {
		this.expires = expires;
	}

	
	private String questMasterKey;
	private String title;
	private String description;
	private Date expires;
	private String questerKey;
	private boolean completed;
	
}
