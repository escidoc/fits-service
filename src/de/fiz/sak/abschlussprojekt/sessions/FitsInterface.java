package de.fiz.sak.abschlussprojekt.sessions;

import java.io.File;

import edu.harvard.hul.ois.fits.exceptions.FitsException;

public interface FitsInterface {
	
	public String extractMetadata(File f) throws FitsException;

}
