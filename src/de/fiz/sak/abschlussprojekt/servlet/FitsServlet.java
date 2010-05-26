package de.fiz.sak.abschlussprojekt.servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import de.fiz.sak.abschlussprojekt.sessions.FitsInterface;
import de.fiz.sak.abschlussprojekt.sessions.impl.FitsInterfaceImpl;
import edu.harvard.hul.ois.fits.exceptions.FitsException;

public class FitsServlet extends HttpServlet {

    private static final long serialVersionUID = -2124267350610278867L;

    private FitsInterface fi = new FitsInterfaceImpl();

    private PrintWriter w;

    private File f;

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

        if (path.startsWith("http")) {
            URL url = new URL(path);
            HttpURLConnection urlConn =
                (HttpURLConnection) url.openConnection();
            urlConn.setRequestMethod("GET");
            String fileName = url.getFile();
            int slashIndex = fileName.lastIndexOf('/');
            fileName = fileName.substring(slashIndex + 1);

            // System.out.println("FileName: " + fileName);

            InputStream is = url.openStream();

            File f = new File("C:\\" + fileName);
            is = new FileInputStream(f);

            OutputStream out =
                new FileOutputStream(new File("C:\\new" + fileName));
            byte buf[] = new byte[1024];
            out.write(buf);
            out.close();
            is.close();

        }
        else if (path.startsWith("file")) {
            String[] split = path.split("file:///");
            path = split[1];

        }

        this.testParameter(path);

        String xml = null;

        try {
            xml = fi.extractMetadata(f);
        }
        catch (FitsException e) {
            throw new ServletException(e);
        }

        if (xml != null) {
            w = resp.getWriter();
            w.println(xml);
        }
    }

    /**
     * Tests the path of the file about the rightness.
     * 
     * @param Pfad
     *            The path of the file.
     * @throws ServletException
     * @throws FileNotFoundException
     */
    private void testParameter(String Pfad) throws ServletException,
        FileNotFoundException {
        f = new File(Pfad);
        if (f.canRead() != true) {
            w.println(new FileNotFoundException("File can not be found!"));
        }
    }

}
