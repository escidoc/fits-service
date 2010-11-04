package org.escidoc.tme;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.escidoc.tme.exceptions.MetadataExtractorException;
import org.escidoc.tme.fits.FitsMetadataExtractor;

public class TechnicalMetadataExtractorServlet extends HttpServlet {

	private static final long serialVersionUID = -2124267350610278867L;

	/**
	 * Implements the HTTP get-request
	 * 
	 * @param req
	 *            HttpServletRequest
	 * @param resp
	 *            HttpServletResponse
	 */
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		String path = req.getParameter("path");
		if (path == null || path.trim().length() == 0) {
			String msg = "Parameter 'path' is required. Try .../examine?path=[local-path|remote-path]";
			resp.sendError(HttpServletResponse.SC_BAD_REQUEST, msg);
		} else {

			String xml = null;
			resp.setContentType("text/xml");

			try {
				// TODO factory?
				MetadataExtractor me = new FitsMetadataExtractor();
				xml = me.extractMetadata(path);
			} catch (MetadataExtractorException e) {
				String msg = "Error extracting metadata: "
						+ e.getLocalizedMessage();
				resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
						msg);
				// throw new ServletException(e);
			} catch (IOException e) {
				String msg = "Input/Output Error extracting metadata: "
						+ e.getLocalizedMessage();
				resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
						msg);
				// throw new ServletException(e);
			}

			if (xml != null) {
				PrintWriter w = resp.getWriter();
				w.println(xml);
			}
		}
	}

}
