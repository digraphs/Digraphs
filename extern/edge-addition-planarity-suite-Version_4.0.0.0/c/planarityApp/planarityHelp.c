/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

char *GetProjectTitle(void)
{
    static char projectTitle[MAXLINE + 1];
    sprintf(projectTitle,
            "\n==================================================="
            "\nThe Edge Addition Planarity Suite version %s"
            "\nbased on libPlanarity graph library version %s"
            "\nCopyright (c) 1997-2025 by John M. Boyer"
            "\nAll rights reserved."
            "\nSee the LICENSE.TXT file for licensing information."
            "\nContact info: jboyer at acm.org"
            "\n===================================================\n",
            gp_GetProjectVersionFull(),
            gp_GetLibPlanarityVersionFull());

    return projectTitle;
}

/****************************************************************************
 helpMessage()
 ****************************************************************************/

int helpMessage(char *param)
{
    Message(GetProjectTitle());

    if (param == NULL)
    {
        Message(
            "'planarity': if no command-line, then menu-driven\n"
            "'planarity (-h|-help)': this message\n"
            "'planarity (-h|-help) -menu': more help with menu-based command line\n"
            "'planarity (-i|-info): copyright and license information\n"
            "'planarity -test [-q] [samples dir]': runs tests (optional quiet mode)\n"
            "\n");

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
            "Process returns 0=planar, 1=nonplanar, -1=error\n");
    }

    else if (strcmp(param, "-i") == 0 || strcmp(param, "-info") == 0)
    {
        Message(
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
            "\n");
    }

    else if (strcmp(param, "-menu") == 0)
    {
        Message(
            "'planarity -r [-q] C K N [O]': Random graphs\n"
            "'planarity -s [-q] C I O [O2]': Specific graph\n"
            "'planarity -rm [-q] N O [O2]': Random maximal planar graph\n"
            "'planarity -rn [-q] N O [O2]': Random nonplanar graph (maximal planar + edge)\n"
            "'planarity -t [-q] C I O': Test algorithm on graph(s) in .g6 file\n"
            "'planarity -x [-q] -(gam) I O': Transform graph to .g6 (g), Adjacency List (a), or Adjacency Matrix (m)\n"
            "'planarity I O [-n O2]': Legacy command-line (default -s -p)\n"
            "\n");

        Message("-q is for quiet mode (no messages to stdout and stderr)\n\n");

        Message(GetAlgorithmFlags());

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
            "    For -rm and -rn, O2 contains the original randomly generated graph\n"
            "\n");

        Message(
            "planarity process results: 0=OK, -1=NOTOK, 1=NONEMBEDDABLE\n"
            "    1 result only produced by specific graph mode (-s)\n"
            "      with command -2,-3,-4: found K_{2,3}, K_{3,3} or K_4\n"
            "      with command -p,-d: found planarity obstruction\n"
            "      with command -o: found outerplanarity obstruction\n");
    }

    FlushConsole(stdout);
    return OK;
}
