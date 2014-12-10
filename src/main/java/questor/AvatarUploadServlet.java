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
import com.google.appengine.api.taskqueue.Queue;
import com.google.appengine.api.taskqueue.QueueFactory;

import static com.google.appengine.api.taskqueue.TaskOptions.Builder.*;



public class AvatarUploadServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = -4503126180486368133L;
	
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
    

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse res)    
        throws ServletException, IOException {

    	HttpSession session = req.getSession();
    	String email_address = (String) session.getAttribute("email_address");
    	
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
        	
        	Queue queue = QueueFactory.getDefaultQueue();
        	queue.add(withUrl("/user/updateAvatar").param("user", email_address).param("blob_key", blobKeys.get(0).getKeyString()));
        }
        
        res.sendRedirect("/user/profile.jsp");
    }
}

