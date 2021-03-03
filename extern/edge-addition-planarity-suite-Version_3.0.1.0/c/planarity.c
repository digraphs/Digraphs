/*
Copyright (c) 1997-2020, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

void ProjectTitle()
{
	// This message is the main location of the version number.
	// The format is major.minor.maintenance.tweak
	// Major is for an overhaul (e.g. many features, data structure change, change of backward compatibility)
	// Minor is for a feature addition (e.g. a new algorithm implementation added, new interface)
	// Maintenance is for functional revision (e.g. bug fix to existing algorithm implementation)
	// Tweak is for a non-functional revision (e.g. change of build scripts or testing code, user-facing string changes)

	// If the version here is increased, also increase it in configure.ac
	// Furthermore, a change of Major, Minor or Maintenance here should cause a change
	// of Current, Revision and/or Age as documented in configure.ac

    Message("\n=================================================="
            "\nThe Edge Addition Planarity Suite version 3.0.1.0"
            "\nCopyright (c) 1997-2020 by John M. Boyer"
    		"\nContact info: jboyer at acm.org"
            "\n=================================================="
            "\n");
}

/****************************************************************************
 MAIN
 ****************************************************************************/

int main(int argc, char *argv[])
{
	int retVal=0;

	if (argc <= 1)
		retVal = menu();

	else if (argv[1][0] == '-')
		retVal = commandLine(argc, argv);

	else
		retVal = legacyCommandLine(argc, argv);

	// Close the log file if logging
	gp_Log(NULL);

	return retVal;
}

/****************************************************************************
 helpMessage()
 ****************************************************************************/

int helpMessage(char *param)
{
	char *commandStr =
    	"C = command (algorithm implementation to run)\n"
    	"    -p = Planar embedding and Kuratowski subgraph isolation\n"
        "    -d = Planar graph drawing by visibility representation\n"
        "    -o = Outerplanar embedding and obstruction isolation\n"
        "    -2 = Search for subgraph homeomorphic to K_{2,3}\n"
        "    -3 = Search for subgraph homeomorphic to K_{3,3}\n"
        "    -4 = Search for subgraph homeomorphic to K_4\n"
		"    -a = All of the above\n"
    	"\n";

	ProjectTitle();

	if (param == NULL)
	{
	    Message(
            "'planarity': if no command-line, then menu-driven\n"
            "'planarity (-h|-help)': this message\n"
            "'planarity (-h|-help) -menu': more help with menu-based command line\n"
	        "'planarity (-i|-info): copyright and license information\n"
    	    "'planarity -test [-q] [C]': runs tests (optional quiet mode, single test)\n"
	    	"\n"
	    );

	    Message(
	    	"Common usages\n"
	    	"-------------\n"
            "planarity -s -q -p infile.txt embedding.out [obstruction.out]\n"
	    	"Process infile.txt in quiet mode (-q), putting planar embedding in \n"
	    	"embedding.out or (optionally) a Kuratowski subgraph in Obstruction.out\n"
	    	"Process returns 0=planar, 1=nonplanar, -1=error\n"
	    	"\n"
            "planarity -s -q -d infile.txt embedding.out [drawing.out]\n"
            "If graph in infile.txt is planar, then put embedding in embedding.out \n"
            "and (optionally) an ASCII art drawing in drawing.out\n"
            "Process returns 0=planar, 1=nonplanar, -1=error\n"
	    );
	}

	else if (strcmp(param, "-i") == 0 || strcmp(param, "-info") == 0)
	{
	    Message(
		    "The Edge Addition Planarity Suite version 3.0.1.0\n"
	    	"Copyright (c) 1997-2020, John M. Boyer\n"
		    "All rights reserved. \n"
	    	"See the LICENSE.TXT file for licensing information. \n"
            "\n"
	    	"Includes a reference implementation of the following:\n"
            "\n"
	    	"* John M. Boyer. \"Subgraph Homeomorphism via the Edge Addition Planarity \n"
	    	"  Algorithm\".  Journal of Graph Algorithms and Applications, Vol. 16, \n"
	    	"  no. 2, pp. 381-410, 2012. http://dx.doi.org/10.7155/jgaa.00268\n"
            "\n"
		    "* John M. Boyer. \"A New Method for Efficiently Generating Planar Graph\n"
		    "  Visibility Representations\". In P. Eades and P. Healy, editors,\n"
		    "  Proceedings of the 13th International Conference on Graph Drawing 2005,\n"
		    "  Lecture Notes Comput. Sci., Volume 3843, pp. 508-511, Springer-Verlag, 2006.\n"
	    	"  http://dx.doi.org/10.1007/11618058_47\n"
            "\n"
		    "* John M. Boyer and Wendy J. Myrvold. \"On the Cutting Edge: Simplified O(n)\n"
		    "  Planarity by Edge Addition\". Journal of Graph Algorithms and Applications,\n"
		    "  Vol. 8, No. 3, pp. 241-273, 2004. http://dx.doi.org/10.7155/jgaa.00091\n"
            "\n"
		    "* John M. Boyer. \"Simplified O(n) Algorithms for Planar Graph Embedding,\n"
		    "  Kuratowski Subgraph Isolation, and Related Problems\". Ph.D. Dissertation,\n"
		    "  University of Victoria, 2001. https://dspace.library.uvic.ca/handle/1828/9918\n"
            "\n"
	    );
	}

	else if (strcmp(param, "-menu") == 0)
	{
	    Message(
	    	"'planarity -r [-q] C K N': Random graphs\n"
	    	"'planarity -s [-q] C I O [O2]': Specific graph\n"
	        "'planarity -rm [-q] N O [O2]': Maximal planar random graph\n"
	        "'planarity -rn [-q] N O [O2]': Nonplanar random graph (maximal planar + edge)\n"
	        "'planarity I O [-n O2]': Legacy command-line (default -s -p)\n"
	    	"\n"
	    );

	    Message("-q is for quiet mode (no messages to stdout and stderr)\n\n");

	    Message(commandStr);

	    Message(
	    	"K = # of graphs to randomly generate\n"
	    	"N = # of vertices in each randomly generated graph\n"
	        "I = Input file (for work on a specific graph)\n"
	        "O = Primary output file\n"
	        "    For example, if C=-p then O receives the planar embedding\n"
	    	"    If C=-3, then O receives a subgraph containing a K_{3,3}\n"
	        "O2= Secondary output file\n"
	    	"    For -s, if C=-p or -o, then O2 receives the embedding obstruction\n"
	       	"    For -s, if C=-d, then O2 receives a drawing of the planar graph\n"
	    	"    For -m and -n, O2 contains the original randomly generated graph\n"
	    	"\n"
	    );

	    Message(
	        "planarity process results: 0=OK, -1=NOTOK, 1=NONEMBEDDABLE\n"
	    	"    1 result only produced by specific graph mode (-s)\n"
	        "      with command -2,-3,-4: found K_{2,3}, K_{3,3} or K_4\n"
	    	"      with command -p,-d: found planarity obstruction\n"
	    	"      with command -o: found outerplanarity obstruction\n"
	    );
	}

    FlushConsole(stdout);
    return 0;
}

/****************************************************************************
 MENU-DRIVEN PROGRAM
 ****************************************************************************/

int menu()
{
char Choice;

     do {
    	ProjectTitle();

        Message("\n"
                "P. Planar embedding and Kuratowski subgraph isolation\n"
                "D. Planar graph drawing by visibility representation\n"
                "O. Outerplanar embedding and obstruction isolation\n"
                "2. Search for subgraph homeomorphic to K_{2,3}\n"
                "3. Search for subgraph homeomorphic to K_{3,3}\n"
                "4. Search for subgraph homeomorphic to K_4\n"
        		"H. Help message for command line version\n"
                "R. Reconfigure options\n"
                "X. Exit\n"
        		"\n"
        );

        Prompt("Enter Choice: ");
        fflush(stdin);
        scanf(" %c", &Choice);
        Choice = tolower(Choice);

        if (Choice == 'h')
        	helpMessage(NULL);

        else if (Choice == 'r')
        	Reconfigure();

        else if (Choice != 'x')
        {
        	char *secondOutfile = NULL;
        	if (Choice == 'p'  || Choice == 'd' || Choice == 'o')
        		secondOutfile ="";

            if (!strchr("pdo234", Choice)) {
            	Message("Invalid menu choice, please try again.");
            } else {
            	switch (tolower(Mode))
                {
                    case 's' : SpecificGraph(Choice, NULL, NULL, secondOutfile); break;
                    case 'r' : RandomGraphs(Choice, 0, 0); break;
                    case 'm' : RandomGraph(Choice, 0, 0, NULL, NULL); break;
                    case 'n' : RandomGraph(Choice, 1, 0, NULL, NULL); break;
                }
            }
        }

        if (Choice != 'r' && Choice != 'x')
        {
            Prompt("\nPress a key then hit ENTER to continue...");
            fflush(stdin);
            scanf(" %*c");
            fflush(stdin);
            Message("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
            FlushConsole(stdout);
        }

     }  while (Choice != 'x');

     // Certain debuggers don't terminate correctly with pending output content
     FlushConsole(stdout);
     FlushConsole(stderr);

     return 0;
}
