package questor;

import java.io.BufferedReader;
import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import questor.Quest.ValueError;

import com.google.appengine.api.datastore.EntityNotFoundException;


public class QuestServlet extends HttpServlet {
	

    /**
	 * 
	 */
	private static final long serialVersionUID = 6311415145652301522L;

	@Override
    public void doPost(HttpServletRequest req, HttpServletResponse res)  {
		try {
	    	HttpSession session = req.getSession();
	    	if(session.getAttribute("email_address") == null){
	    		res.sendError(403);
	    		return;
	    	}
	    	
	    	User user = null;
			try {
				user = User.fromEmailAddress((String) session.getAttribute("email_address"));
			} catch (EntityNotFoundException e1) {
				res.sendError(403);
				return;
			}
	    	
	    	if(!req.getPathInfo().equals("/new")){
				res.sendError(404);
				return;
	    	}
	    	
	    	if(!req.getContentType().contains("application/json")){
	    		res.sendError(400);
	    		return;
	    	}
	    	
	        BufferedReader reader = req.getReader();
	        String line = null;
	        StringBuffer body = new StringBuffer();
	        while ((line = reader.readLine()) != null)
	        	body.append(line);
	        
	        try {
	        	Quest questData = Quest.fromJSON(body.toString());
	        	Quest newQuest = new Quest(user, questData.getTitle(), 
	        										questData.getDescription(), 
	        										questData.getReward());
	        	
	        	res.sendRedirect("/quests/" + newQuest.getQuestKey().toString());
	        }
	        catch(Quest.ValueError e) {
	        	res.sendError(400);
	        	return;
	        }
	    	
		} 
		catch (IOException e) { } 
		
	}
	
    
    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse res)  {
		try {
	    	HttpSession session = req.getSession();
	    	if(session.getAttribute("email_address") == null){
	    		res.sendError(403);
	    		return;
	    	}
	    	
	    	User user = null;
			try {
				user = User.fromEmailAddress((String) session.getAttribute("email_address"));
			} catch (EntityNotFoundException e1) {
				res.sendError(403);
				return;
			}
			

			try {
				Long id = Long.parseLong(req.getPathInfo().substring(1));
				Quest q = Quest.fromKey(id);
				res.setContentType("application/json");
				res.getWriter().write(q.toJson());
			} catch (NumberFormatException | EntityNotFoundException | ValueError e) {
				res.sendError(404);
				return;
			}
			
		} 
		catch (IOException e) { } 
    }
    
    @Override
    public void doPut(HttpServletRequest req, HttpServletResponse res)  {
		try {
	    	HttpSession session = req.getSession();
	    	if(session.getAttribute("email_address") == null){
	    		res.sendError(403);
	    		return;
	    	}
	    	
	    	User user = null;
			try {
				user = User.fromEmailAddress((String) session.getAttribute("email_address"));
			} catch (EntityNotFoundException e1) {
				res.sendError(403);
				return;
			}
			

			try {
				Long id = Long.parseLong(req.getPathInfo().substring(1));
				Quest origQuest = Quest.fromKey(id);
				
		    	if(!req.getContentType().contains("application/json")){
		    		res.sendError(400);
		    		return;
		    	}
		    	
		        BufferedReader reader = req.getReader();
		        String line = null;
		        StringBuffer body = new StringBuffer();
		        while ((line = reader.readLine()) != null)
		        	body.append(line);
		        
		        try {
		        	Quest questData = Quest.fromJSON(body.toString());
		        	if(questData.getQuesterKey() != null) {
		        		// Quest has been accepted
		        		if(origQuest.getQuesterKey() != null
		        			|| !questData.getQuesterKey().equals(user.getUserKey())){
		        			res.sendError(403);
		        			return;
		        		}
		        		
		        		origQuest.setQuesterKey(questData.getQuesterKey());
		        		origQuest.updateStore();
		        			
		        	}
		        		
		        }
		        catch(Quest.ValueError e) {
		        	res.sendError(400);
		        	return;
		        }
				
			} catch (NumberFormatException | EntityNotFoundException | ValueError e) {
				res.sendError(404);
				return;
			}
			
		} 
		catch (IOException e) { } 
    }
    
    

}
