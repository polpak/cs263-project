package questor;

import java.util.List;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;


public class User {
	
	public class ValueError extends Exception {

		/**
		 * 
		 */
		private static final long serialVersionUID = 3210802226455545038L;

		public ValueError(String string) {
			super(string);
		}
	}
	
	public String getUserKey() {
		return userKey;
	}

	public String getEmailAddress() {
		return emailAddress;
	}

	public String getFirstName() {
		return firstName;
	}
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	public String getLastName() {
		return lastName;
	}
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	
	
	public static User fromEmailAddress(String email) throws EntityNotFoundException {
	    Key key = KeyFactory.createKey("User", email);
	    Entity user = GAEDatastore.get(key);
	    
	    return User.fromEntity(user);
	}
	
	private static User fromEntity(Entity user) {
		User u = new User();
		u.emailAddress = (String) user.getProperty("email_address");
		u.userKey = u.emailAddress; 
		u.setFirstName((String) user.getProperty("first_name"));
		u.setLastName((String) user.getProperty("last_name"));
		return u;
	}
	
	
	public List<Quest> getPostedQuests() {
		return Quest.findByQuestMaster(this);
	}
	
	public List<Quest> getAcceptedQuests() {
		return Quest.findByQuester(this);
	}
	
	private static DatastoreService GAEDatastore = DatastoreServiceFactory.getDatastoreService();
	
	private String userKey;
	private String emailAddress;
	private String firstName;
	private String lastName;
	
}
