package de.fiz.sak.abschlussprojekt.sessions.impl;

import java.io.File;
import java.util.Iterator;

import org.jdom.Document;
import org.jdom.output.XMLOutputter;

import de.fiz.sak.abschlussprojekt.sessions.FitsInterface;
import edu.harvard.hul.ois.fits.Fits;
import edu.harvard.hul.ois.fits.FitsOutput;
import edu.harvard.hul.ois.fits.exceptions.FitsException;
import edu.harvard.hul.ois.fits.exceptions.FitsToolException;

public class FitsInterfaceImpl implements FitsInterface {

    @Override
    public String extractMetadata(File f) throws FitsException {
        String x = null;

        Fits fits = null;
        fits = new Fits();
        System.out.println("FITS_HOME=" + Fits.FITS_HOME);

        FitsOutput fitsOut;
        fitsOut = fits.examine(f);

        Iterator<Exception> it = fitsOut.getCaughtExceptions().iterator();
        FitsException fe = null;
        while (it.hasNext()) {
            Exception e = it.next();
            if (fe == null) {
                fe =
                    new FitsToolException("Caught at least one ToolException.",
                        e);
            }
            e.printStackTrace();
        }
        if (fe != null) {
            throw fe;
        }

        Document doc = fitsOut.getFitsXml();

        XMLOutputter outputter = new XMLOutputter();
        x = outputter.outputString(doc);

        return x;

    }

}
