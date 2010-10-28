package org.escidoc.tme.fits;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.Iterator;
import java.util.zip.Adler32;
import java.util.zip.Checksum;

import javax.servlet.ServletException;

import org.escidoc.tme.MetadataExtractor;
import org.jdom.Content;
import org.jdom.Document;
import org.jdom.ProcessingInstruction;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;

import edu.harvard.hul.ois.fits.Fits;
import edu.harvard.hul.ois.fits.FitsOutput;
import edu.harvard.hul.ois.fits.exceptions.FitsException;
import edu.harvard.hul.ois.fits.exceptions.FitsToolException;

public class FitsMetadataExtractor implements MetadataExtractor {

	// FIXME
	private File f;

	private final boolean omitXmlDeclaration;

	private String xsltUrl;

	/**
	 * Result from extracting metadata does not contain XML header. If XML
	 * header needed use FitsInterfaceImpl(boolean omitXmlDeclaration = false).
	 */
	public FitsMetadataExtractor() {
		super();
		this.omitXmlDeclaration = true;
		this.xsltUrl = null;
	}

	public FitsMetadataExtractor(boolean omitXmlDeclaration) {
		super();
		this.omitXmlDeclaration = omitXmlDeclaration;
		this.xsltUrl = null;
	}

	public FitsMetadataExtractor(String xsltUrl) {
		super();
		this.omitXmlDeclaration = true;
		this.xsltUrl = xsltUrl;
	}

	public FitsMetadataExtractor(boolean omitXmlDeclaration, String xsltUrl) {
		super();
		this.omitXmlDeclaration = omitXmlDeclaration;
		this.xsltUrl = xsltUrl;
	}

	@Override
	public String extractMetadata(String locator) throws FitsException,
			IOException {

		// String to ...

		if (locator.startsWith("http")) {
			URL url = new URL(locator);
			HttpURLConnection urlConn = (HttpURLConnection) url
					.openConnection();
			urlConn.setRequestMethod("GET");

			// get a name for the file
			String fileName = url.getPath();
			int slashIndex = fileName.lastIndexOf('/');
			if (slashIndex == fileName.length() - 1) {
				// url ends with /
				fileName = fileName.substring(0, slashIndex);
				slashIndex = fileName.lastIndexOf('/');
			}
			fileName = fileName.substring(slashIndex + 1);

			String dirPath = locator.substring(0, locator.indexOf(fileName));
			byte[] dirPathBytes = dirPath.getBytes(Charset.forName("UTF-8"));
			Checksum cs = new Adler32();
			cs.update(dirPathBytes, 0, dirPathBytes.length);

			InputStream is = url.openStream();

			// create tmp-file from hashed URL (without filename) and filename
			File tmpFile = File.createTempFile(String.valueOf(cs.getValue()),
					fileName);
			// TODO check if delete on exit of VM is sufficient; may be better
			// to delete on servlet destruction
			tmpFile.deleteOnExit();
			OutputStream out = new FileOutputStream(tmpFile);

			// download
			byte[] buffer = new byte[2048];
			int bytesRead = is.read(buffer);
			while (bytesRead >= 0) {
				out.write(buffer, 0, bytesRead);
				bytesRead = is.read(buffer);
			}
			out.close();
			is.close();

			locator = tmpFile.getAbsolutePath();// Name;
		} else if (locator.startsWith("file:///")) {
			locator = locator.replaceFirst("file:///", "");
		}

		this.testParameter(locator);

		// .. File

		String fitsXml = null;

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
				fe = new FitsToolException(
						"Caught at least one ToolException.", e);
			}
			e.printStackTrace();
		}
		if (fe != null) {
			throw fe;
		}

		Document doc = fitsOut.getFitsXml();

		if (this.xsltUrl != null) {
			Content pi = new ProcessingInstruction("xml-stylesheet",
					"type=\"text/xsl\" href=\"" + this.xsltUrl + "\"");
			doc.addContent(0, pi);
		}

		Format format = Format.getPrettyFormat();
		format.setOmitDeclaration(this.omitXmlDeclaration);
		XMLOutputter outputter = new XMLOutputter(format);
		fitsXml = outputter.outputString(doc);

		return fitsXml;
		
	}

	/**
	 * Tests the path of the file about the rightness.
	 * 
	 * @param Pfad
	 *            The path of the file.
	 * @throws ServletException
	 * @throws FileNotFoundException
	 */
	private void testParameter(String Pfad) throws FileNotFoundException {
		// FIXME side condition
		f = new File(Pfad);
		if (f == null) {
			throw new FileNotFoundException("Cannot open file: " + Pfad);
		}
		if (f.canRead() != true) {
			throw new FileNotFoundException("Cannot read file: " + Pfad);
		}
	}

}
