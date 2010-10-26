package org.escidoc.tme;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.escidoc.tme.fits.FitsMetadataExtractor;

import edu.harvard.hul.ois.fits.exceptions.FitsException;

public class TechnicalMetadataExtractorServlet extends HttpServlet {

    private static final long serialVersionUID = -2124267350610278867L;

    private MetadataExtractor fi = new FitsMetadataExtractor();

    private PrintWriter w;
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

        if (path == null) {
            throw new ServletException("Parameter 'path' not set. ");
        }

        

        String xml = null;

        try {
            xml = fi.extractMetadata(path);
        }
        catch (FitsException e) {
            throw new ServletException(e);
        }

        if (xml != null) {
            w = resp.getWriter();
            w.println(xml);
        }
    }

}