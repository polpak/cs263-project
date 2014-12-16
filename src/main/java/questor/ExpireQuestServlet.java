package questor;



import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.taskqueue.Queue;
import com.google.appengine.api.taskqueue.QueueFactory;
import com.google.appengine.api.taskqueue.TaskOptions.Method;

import static com.google.appengine.api.taskqueue.TaskOptions.Builder.*;



public class ExpireQuestServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = -2924496050669712488L;

	@Override
    public void doGet(HttpServletRequest req, HttpServletResponse res)  {
		try {
			if(req.getRequestURI().equals("/maintenance/startExpireQuests")) {
		        Queue queue = QueueFactory.getDefaultQueue();
		        queue.add(withUrl("/maintenance/processExpireQuests").method(Method.GET));
		        res.sendRedirect("/");

			}
			else if(req.getRequestURI().equals("/maintenance/processExpireQuests")) {
				
				Quest.expireQuests();
				
				res.setContentType("text/plain");
				res.getWriter().write("OK.");
			}
			else
				res.sendError(404);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
}
