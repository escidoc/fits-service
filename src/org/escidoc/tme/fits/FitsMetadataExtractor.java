package org.escidoc.tme.fits;

import java.io.File;
import java.util.Iterator;

import org.escidoc.tme.MetadataExtractor;
import org.jdom.Document;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;

import edu.harvard.hul.ois.fits.Fits;
import edu.harvard.hul.ois.fits.FitsOutput;
import edu.harvard.hul.ois.fits.exceptions.FitsException;
import edu.harvard.hul.ois.fits.exceptions.FitsToolException;

public class FitsMetadataExtractor implements MetadataExtractor {

    private final boolean omitXmlDeclaration;

    /**
     * Result from extracting metadata does not contain XML header. If XML
     * header needed use FitsInterfaceImpl(boolean omitXmlDeclaration = false).
     */
    public FitsMetadataExtractor() {
        super();
        this.omitXmlDeclaration = true;
    }

    public FitsMetadataExtractor(boolean omitXmlDeclaration) {
        super();
        this.omitXmlDeclaration = omitXmlDeclaration;
    }

    @Override
    public String extractMetadata(File f) throws FitsException {
        String x = null;

        Fits fits = null;
        fits = new Fits();
        // System.out.println("FITS_HOME=" + Fits.FITS_HOME);

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

        Format format = Format.getPrettyFormat();
        format.setOmitDeclaration(this.omitXmlDeclaration);
        XMLOutputter outputter = new XMLOutputter(format);
        x = outputter.outputString(doc);

        return x;

    }

}
