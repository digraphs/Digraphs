/*
Copyright (c) 1997-2020, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

/****************************************************************************
 Configuration
 ****************************************************************************/

char Mode='r',
     OrigOut='n',
     EmbeddableOut='n',
     ObstructedOut='n',
     AdjListsForEmbeddingsOut='n',
     quietMode='n';

void Reconfigure()
{
     fflush(stdin);

     Prompt("\nDo you want to \n"
    		"  Randomly generate graphs (r),\n"
    		"  Specify a graph (s),\n"
    		"  Randomly generate a maximal planar graph (m), or\n"
    		"  Randomly generate a non-planar graph (n)?");
     scanf(" %c", &Mode);

     Mode = tolower(Mode);
     if (!strchr("rsmn", Mode))
    	 Mode = 's';

     if (Mode == 'r')
     {
        Message("\nNOTE: The directories for the graphs you want must exist.\n\n");

        Prompt("Do you want original graphs in directory 'random' (last 10 max)?");
        scanf(" %c", &OrigOut);

        Prompt("Do you want adj. matrix of embeddable graphs in directory 'embedded' (last 10 max))?");
        scanf(" %c", &EmbeddableOut);

        Prompt("Do you want adj. matrix of obstructed graphs in directory 'obstructed' (last 10 max)?");
        scanf(" %c", &ObstructedOut);

        Prompt("Do you want adjacency list format of embeddings in directory 'adjlist' (last 10 max)?");
        scanf(" %c", &AdjListsForEmbeddingsOut);
     }

     FlushConsole(stdout);
}

/****************************************************************************
 MESSAGE - prints a string, but when debugging adds \n and flushes stdout
 ****************************************************************************/

#define MAXLINE 1024
char Line[MAXLINE];

void Message(char *message)
{
	if (quietMode == 'n')
	{
	    fprintf(stdout, "%s", message);
	    fflush(stdout);
	}
}

void ErrorMessage(char *message)
{
	if (quietMode == 'n')
	{
		fprintf(stderr, "%s", message);
		fflush(stderr);
	}
}

void FlushConsole(FILE *f)
{
	    fflush(f);
}

void Prompt(char *message)
{
	Message(message);
	FlushConsole(stdout);
}

/****************************************************************************
 ****************************************************************************/

void SaveAsciiGraph(graphP theGraph, char *filename)
{
	int  e, EsizeOccupied, vertexLabelFix;
	FILE *outfile = fopen(filename, WRITETEXT);

	// The filename may specify a directory that doesn't exist
	if (outfile == NULL)
	{
		sprintf(Line, "Failed to write to %s\nMake the directory if not present\n", filename);
		ErrorMessage(Line);
		return;
	}

	// If filename includes path elements, remove them before writing the file's name to the file
	if (strrchr(filename, FILE_DELIMITER))
		filename = strrchr(filename, FILE_DELIMITER)+1;

	fprintf(outfile, "%s\n", filename);

	// This edge list file format uses 1-based vertex numbering, and the current code
	// internally uses 1-based indexing by default, so this vertex label 'fix' adds zero
	// But earlier code used 0-based indexing and added one on output, so we replicate
	// that behavior in case the current code has been compiled with zero-based indexing.
	vertexLabelFix = 1 - gp_GetFirstVertex(theGraph);

	// Iterate over the edges of the graph
	EsizeOccupied = gp_EdgeInUseIndexBound(theGraph);
	for (e = gp_GetFirstEdge(theGraph); e < EsizeOccupied; e+=2)
	{
		// Only output edges that haven't been deleted (i.e. skip the edge holes)
		if (gp_EdgeInUse(theGraph, e))
		{
			fprintf(outfile, "%d %d\n",
					gp_GetNeighbor(theGraph, e) + vertexLabelFix,
					gp_GetNeighbor(theGraph, e+1) + vertexLabelFix);
		}
	}

	// Since vertex numbers are at least 1, this indicates the end of the edge list
	fprintf(outfile, "0 0\n");

	fclose(outfile);
}

/****************************************************************************
 ****************************************************************************/

int  TextFilesEqual(char *file1Name, char *file2Name)
{
	FILE *infile1 = NULL, *infile2 = NULL;
	int Result = TRUE;

	infile1 = fopen(file1Name, "r");
	infile2 = fopen(file2Name, "r");

	if (infile1 == NULL || infile2 == NULL)
		Result = FALSE;
	else
	{
		int c1=0, c2=0;

		// Read the first file to the end
		while ((c1 = fgetc(infile1)) != EOF)
		{
			// Want to suppress distinction between lines ending with CRLF versus LF
			if (c1 == '\r')
				continue;

			// Get a char from the second file, except suppress CR again
			while ((c2 = fgetc(infile2)) == '\r')
				;

			// If we got a char from the first file, but not from the second
			// then the second file is shorter, so files are not equal
			if (c2 == EOF)
			{
				Result = FALSE;
				break;
			}

			// If we got a char from second file, but not equal to char from
			// first file, then files are not equal
			if (c1 != c2)
			{
				Result = FALSE;
				break;
			}
		}

		// If we got to the end of the first file without breaking the loop...
		if (c1 == EOF)
		{
			// Then, once again, suppress CRs first, and then...
			while ((c2 = fgetc(infile2)) == '\r')
				;
			// Test whether or not the second file also ends, same as the first.
			if (fgetc(infile2) != EOF)
				Result = FALSE;
		}
	}

	if (infile1 != NULL) fclose(infile1);
	if (infile2 != NULL) fclose(infile2);
	return Result;
}

/****************************************************************************
 ****************************************************************************/

int  BinaryFilesEqual(char *file1Name, char *file2Name)
{
	FILE *infile1 = NULL, *infile2 = NULL;
	int Result = TRUE;

	infile1 = fopen(file1Name, "r");
	infile2 = fopen(file2Name, "r");

	if (infile1 == NULL || infile2 == NULL)
		Result = FALSE;
	else
	{
		int c1=0, c2=0;

		// Read the first file to the end
		while ((c1 = fgetc(infile1)) != EOF)
		{
			// If we got a char from the first file, but not from the second
			// then the second file is shorter, so files are not equal
			if ((c2 = fgetc(infile2)) == EOF)
			{
				Result = FALSE;
				break;
			}

			// If we got a char from second file, but not equal to char from
			// first file, then files are not equal
			if (c1 != c2)
			{
				Result = FALSE;
				break;
			}
		}

		// If we got to the end of the first file without breaking the loop...
		if (c1 == EOF)
		{
			// Then attempt to read from the second file to ensure it also ends.
			if (fgetc(infile2) != EOF)
				Result = FALSE;
		}
	}

	if (infile1 != NULL) fclose(infile1);
	if (infile2 != NULL) fclose(infile2);
	return Result;
}

/****************************************************************************
 ****************************************************************************/

int GetEmbedFlags(char command)
{
	int embedFlags = 0;

	switch (command)
	{
		case 'o' : embedFlags = EMBEDFLAGS_OUTERPLANAR; break;
		case 'p' : embedFlags = EMBEDFLAGS_PLANAR; break;
		case 'd' : embedFlags = EMBEDFLAGS_DRAWPLANAR; break;
		case '2' : embedFlags = EMBEDFLAGS_SEARCHFORK23; break;
		case '3' : embedFlags = EMBEDFLAGS_SEARCHFORK33; break;
		case '4' : embedFlags = EMBEDFLAGS_SEARCHFORK4; break;
	}

	return embedFlags;
}

/****************************************************************************
 ****************************************************************************/

char *GetAlgorithmName(char command)
{
	char *algorithmName = "UnsupportedAlgorithm";

	switch (command)
	{
		case 'p' : algorithmName = "PlanarEmbed"; break;
		case 'd' : algorithmName = DRAWPLANAR_NAME;	break;
		case 'o' : algorithmName = "OuterplanarEmbed"; break;
		case '2' : algorithmName = K23SEARCH_NAME; break;
		case '3' : algorithmName = K33SEARCH_NAME; break;
		case '4' : algorithmName = K4SEARCH_NAME; break;
	}

	return algorithmName;
}

/****************************************************************************
 ****************************************************************************/

void AttachAlgorithm(graphP theGraph, char command)
{
	switch (command)
	{
		case 'd' : gp_AttachDrawPlanar(theGraph); break;
		case '2' : gp_AttachK23Search(theGraph); break;
		case '3' : gp_AttachK33Search(theGraph); break;
		case '4' : gp_AttachK4Search(theGraph); break;
	}
}

/****************************************************************************
 A string used to construct input and output filenames.

 The SUFFIXMAXLENGTH is 32 to accommodate ".out.txt" + ".render.txt" + ".test.txt"
 ****************************************************************************/

#define FILENAMEMAXLENGTH 128
#define ALGORITHMNAMEMAXLENGTH 32
#define SUFFIXMAXLENGTH 32

char theFileName[FILENAMEMAXLENGTH+1+ALGORITHMNAMEMAXLENGTH+1+SUFFIXMAXLENGTH+1];

/****************************************************************************
 ConstructInputFilename()
 Returns a string not owned by the caller (do not free string).
 String contains infileName content if infileName is non-NULL.
 If infileName is NULL, then the user is asked to supply a name.
 Returns NULL on error, or a non-NULL string on success.
 ****************************************************************************/

char *ConstructInputFilename(char *infileName)
{
	if (infileName == NULL)
	{
		Prompt("Enter graph file name: ");
		fflush(stdin);
		scanf(" %s", theFileName);

		if (!strchr(theFileName, '.'))
			strcat(theFileName, ".txt");
	}
	else
	{
		if (strlen(infileName) > FILENAMEMAXLENGTH)
		{
			ErrorMessage("Filename is too long");
			return NULL;
		}
		strcpy(theFileName, infileName);
	}

	return theFileName;
}

/****************************************************************************
 ConstructPrimaryOutputFilename()
 Returns a string not owned by the caller (do not free string).
 Reuses the same memory space as ConstructinputFilename().
 If outfileName is non-NULL, then the result string contains its content.
 If outfileName is NULL, then the infileName and the command's algorithm name
 are used to construct a string.
 Returns non-NULL string
 ****************************************************************************/

char *ConstructPrimaryOutputFilename(char *infileName, char *outfileName, char command)
{
	char *algorithmName = GetAlgorithmName(command);

	if (outfileName == NULL)
	{
		// The output filename is based on the input filename
		if (theFileName != infileName)
		    strcpy(theFileName, infileName);

		// If the primary output filename has not been given, then we use
		// the input filename + the algorithm name + a simple suffix
		if (strlen(algorithmName) <= ALGORITHMNAMEMAXLENGTH)
		{
			strcat(theFileName, ".");
			strcat(theFileName, algorithmName);
		}
		else
			ErrorMessage("Algorithm Name is too long, so it will not be used in output filename.");

	    strcat(theFileName, ".out.txt");
	}
	else
	{
		if (strlen(outfileName) > FILENAMEMAXLENGTH)
		{
			// The output filename is based on the input filename
			if (theFileName != infileName)
			    strcpy(theFileName, infileName);

	    	if (strlen(algorithmName) <= ALGORITHMNAMEMAXLENGTH)
	    	{
	    		strcat(theFileName, ".");
	    		strcat(theFileName, algorithmName);
	    	}
	        strcat(theFileName, ".out.txt");
			sprintf(Line, "Outfile filename is too long. Result placed in %s", theFileName);
			ErrorMessage(Line);
		}
		else
		{
			if (theFileName != outfileName)
			    strcpy(theFileName, outfileName);
		}
	}

	return theFileName;
}
