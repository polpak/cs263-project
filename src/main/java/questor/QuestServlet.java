package questor;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import questor.Quest.ValueError;

import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.memcache.ErrorHandlers;
import com.google.appengine.api.memcache.Expiration;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.gson.Gson;


public class QuestServlet extends HttpServlet {
	

    /**
	 * 
	 */
	private static final long serialVersionUID = 6311415145652301522L;

	/*
	 * API enpoint for creating a new quest. Requires a valid user to be logged in.
	 * @see javax.servlet.http.HttpServlet#doPost(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
	 */
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
	
    /*
     * API endpoint for retrieving one quest (or a list of quests) in json format. 
     * Requires a valid user to be logged in. 
     * 
     * @see javax.servlet.http.HttpServlet#doGet(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
     */
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

			
			if(req.getRequestURI().equals("/quests/")) {
				doList(req, res, user);
				return;
			}
			else {
				doShow(req, res, user);
				return;
			}
			
		} 
		catch (IOException e) { } 
    }
    
    /*
     * Called by doGet, this method handles returning a single quest
     */
    private void doShow(HttpServletRequest req, HttpServletResponse res, User user) {
		try {
			try {
				Long id = Long.parseLong(req.getPathInfo().substring(1));
				Quest q = Quest.fromKey(id);
				res.setContentType("application/json");
	
					res.getWriter().write(q.toJson());
	
			} catch (NumberFormatException | EntityNotFoundException | ValueError e) {
				res.sendError(404);
				return;
			}
		} catch (IOException e) {

		}
	}

    /*
     * Called by doGet, this method handles returning a list of quests
     */
	private void doList(HttpServletRequest req, HttpServletResponse res, User user) {
		String key = "quest_list_" + user.getUserKey();
		
		MemcacheService syncCache = (MemcacheService) MemcacheServiceFactory.getMemcacheService();
	    syncCache.setErrorHandler(ErrorHandlers.getConsistentLogAndContinue(Level.INFO));
	    String json= (String) syncCache.get(key); // read from cache
	    
		if(json == null) {
			List<Quest> questList = Quest.getAvailableForUser(user);
			Gson gson = new Gson(); 
			json = gson.toJson(questList);

		    syncCache.put(key, json, Expiration.byDeltaSeconds(60)); // populate cache
		}
		
		res.setContentType("application/json");
		try {
			res.getWriter().write(json);
		} catch (IOException e) {
			
		}

	}


	/*
	 * API endpoint for updating a quest. Allowed updates for completed and questerKey only.
	 * @see javax.servlet.http.HttpServlet#doPut(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
	 */
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
		        	
		        	if(questData.isCompleted()) {
		        		System.out.println("Marking quest complete");
		        		if(!origQuest.isAccepted() 
		        			|| !origQuest.getQuesterKey().equals(user.getUserKey())) {
		        			res.sendError(403);
		        			return;
		        		}
		        		if(!origQuest.isCompleted()) {
		        			origQuest.setCompleted(true);
		        			user.setExperiencePoints(user.getExperiencePoints() + origQuest.getReward());
		        			origQuest.updateStore();
		        			user.updateStore();
		        		}
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
