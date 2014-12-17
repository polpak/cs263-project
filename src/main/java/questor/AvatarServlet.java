package questor;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;




/**
 * Servlet for handling serving and updating avatar images using the blobstore service
 */
public class AvatarServlet extends HttpServlet {

	private static final long serialVersionUID = -4503126180486368133L;
	
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	private DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

	/*
	 * Handles a post request to the servlet and updates the currently logged in user's avatar
	 * in the blobstore.
	 * 
	 * If the session doesn't have a valid user logged in, the method will redirect to the login page
	 * @see javax.servlet.http.HttpServlet#doPost(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
	 */
    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse res)    
        throws ServletException, IOException {

    	HttpSession session = req.getSession();
    	String email_address = (String) session.getAttribute("email_address");
    	Key userKey = KeyFactory.createKey("User", email_address);
    	
    	if(email_address == null) {
    		res.sendRedirect("/user/login.jsp");
    		return;
    	}
    		
    	
        Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(req);
        for(String param : blobs.keySet()) {
        	if(!param.equals("user_avatar"))
        		for(BlobKey key : blobs.get(param)){
        			blobstoreService.delete(key);
        		}
        }

        List<BlobKey> blobKeys = blobs.get("user_avatar");
        
        if (blobKeys != null && !blobKeys.isEmpty()) {
        	for(int i=1; i < blobKeys.size(); i++)
        		blobstoreService.delete(blobKeys.get(i));
        	

        	BlobKey newBlobKey = blobKeys.get(0);
        	
		    try {
				Entity user = datastore.get(userKey);
				if(user.hasProperty("avatar_key")) {
					BlobKey oldBlobKey = new BlobKey((String)user.getProperty("avatar_key"));
					blobstoreService.delete(oldBlobKey);
			    }
				
				System.out.println("CSLOG -- updating avatar");
			    
			    
			    user.setProperty("avatar_key", newBlobKey.getKeyString());
			    datastore.put(user);
			    
			} catch (EntityNotFoundException e) {
				System.out.println("CSLOG -- failed to update avatar");
				System.out.println(e.toString());
				blobstoreService.delete(newBlobKey);
			}
        }
        
        res.sendRedirect("/user/profile.jsp");
    }
    

    /*
     * Handles a get request to the servlet and serves the currently logged in user's avatar
	 * from the blobstore.
	 * 
	 * If the session doesn't have a valid user logged in, the method will redirect to the login page
	 * @see javax.servlet.http.HttpServlet#doGet(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
	 */
    public void doGet(HttpServletRequest req, HttpServletResponse res) 
    		throws IOException {
	    	HttpSession session = req.getSession();
	    	String email_address = (String) session.getAttribute("email_address");
	    	
	    	if(email_address == null) {
	    		res.sendError(403);
	    		return;
	    	}
	    	DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
		    Key userKey = KeyFactory.createKey("User", (String)session.getAttribute("email_address"));
		    try {
				Entity user = datastore.get(userKey);
				if(!user.hasProperty("avatar_key")) {
					res.sendRedirect("/images/default_avatar.svg");
			    }
			    else {
			        BlobKey blobKey = new BlobKey((String)user.getProperty("avatar_key"));
			        blobstoreService.serve(blobKey, res);	
			    }
			} catch (EntityNotFoundException e) {
	    		res.sendError(403);
			}
    }
}

