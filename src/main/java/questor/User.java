package questor;

import java.util.List;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Transaction;

/*
 * The User model wraps the GAE entities for ease of use in JSP and servlets
 */
public class User {
	
	
	/*
	 * Exception used for data validation
	 */
	public class ValueError extends Exception {

		/**
		 * 
		 */
		private static final long serialVersionUID = 3210802226455545038L;

		public ValueError(String string) {
			super(string);
		}
	}
	
	/*
	 * Getter for the userKey field (this is the same as emailAddress)
	 */
	public String getUserKey() {
		return userKey;
	}

	/*
	 * Getter for the emailAddress field
	 */
	public String getEmailAddress() {
		return emailAddress;
	}

	/*
	 * Getter for the firstName field
	 */
	public String getFirstName() {
		return firstName;
	}
	
	/*
	 * Setter for the firstName field
	 */
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	
	/*
	 * Getter for the lastName field
	 */
	public String getLastName() {
		return lastName;
	}
	
	/*
	 * Setter for the lastName field
	 */
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	
	/*
	 * Getter for the experiencePoints field
	 */
	public Long getExperiencePoints() {
		return experiencePoints;
	}

	
	/*
	 * Setter for the experiencePoints field
	 */
	public void setExperiencePoints(Long experiencePoints) {
		this.experiencePoints = experiencePoints;
	}
	
	/*
	 * Gets a user from the datastore by their email address
	 * 
	 * @param	email	the emailAddress of the user
	 */
	public static User fromEmailAddress(String email) throws EntityNotFoundException {
	    Key key = KeyFactory.createKey("User", email);
	    Entity user = GAEDatastore.get(key);
	    
	    return User.fromEntity(user);
	}
	
	/*
	 * Constructs a user from an Entity (used internally)
	 */
	private static User fromEntity(Entity user) {
		User u = new User();
		u.emailAddress = (String) user.getProperty("email_address");
		u.userKey = u.emailAddress; 
		u.setFirstName((String) user.getProperty("first_name"));
		u.setLastName((String) user.getProperty("last_name"));
		u.setExperiencePoints((Long) user.getProperty("experience_points"));
		return u;
	}
	
	/*
	 * Gets all the quests posted by the user
	 */
	public List<Quest> getPostedQuests() {
		return Quest.findByQuestMaster(this);
	}
	
	/*
	 * Gets all the quests accepted by the user
	 */
	public List<Quest> getAcceptedQuests() {
		return Quest.findByQuester(this);
	}
	

	/*
	 * Saves the user to the datastore. Currently only updates experience points.
	 */
	public void updateStore() {
		Key key = KeyFactory.createKey("User", this.getUserKey());
		Transaction txn = GAEDatastore.beginTransaction();
	    try {
	    	
			Entity userEntity = GAEDatastore.get(key);
			userEntity.setProperty("experience_points", this.getExperiencePoints());
			GAEDatastore.put(userEntity);
		} catch (EntityNotFoundException e) {
			txn.rollback();
		}
	    txn.commit();
	}

	private static DatastoreService GAEDatastore = DatastoreServiceFactory.getDatastoreService();
	
	private String userKey;
	private String emailAddress;
	private String firstName;
	private String lastName;
	private Long experiencePoints;

	
}
