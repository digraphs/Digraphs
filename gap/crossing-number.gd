# Properties
DeclareProperty("IsSemicompleteDigraph", IsDigraph);
DeclareProperty("IsCubicDigraph", IsDigraph);

# Operations
DeclareOperation("DigraphAddVertexCrossingPoint", [IsDigraph, IsList, IsList]);

# Global Functions
DeclareGlobalFunction("DigraphCrossingNumberUpperBound");
DeclareGlobalFunction("DigraphCrossingNumberLowerBound");
DeclareGlobalFunction("DIGRAPHS_CrossingNumberInequality");
DeclareGlobalFunction("DIGRAPHS_GetCompleteDigraphCrossingNumber");
DeclareGlobalFunction("DIGRAPHS_CrossingNumberAlbertson");
DeclareGlobalFunction("DIGRAPHS_CrossingNumberRound");
DeclareGlobalFunction("DIGRAPHS_IsK22FreeDigraph");
DeclareGlobalFunction("DIGRAPHS_ZarankiewiczTheorem");
DeclareGlobalFunction("DIGRAPHS_CompleteTripartiteDigraphCrossingNumber");
DeclareGlobalFunction("DIGRAPHS_Complete6partiteDigraphCrossingNumber");
DeclareGlobalFunction("DIGRAPHS_Complete5partiteDigraphCrossingNumber");
DeclareGlobalFunction("DIGRAPHS_Complete4partiteDigraphCrossingNumber");
DeclareGlobalFunction("DIGRAPHS_IsomorphicToCirculantGraphCrossingNumber");

# Attributes
DeclareAttribute("DIGRAPHS_CompleteDigraphCrossingNumber", IsCompleteDigraph);
DeclareAttribute("DIGRAPHS_TournamentCrossingNumber", IsTournament);
DeclareAttribute("DigraphCrossingNumber", IsDigraph);
DeclareAttribute("SemicompleteDigraphCrossingNumber", IsSemicompleteDigraph);
DeclareAttribute("DigraphAllThreeCycles", IsDigraph);
DeclareAttribute("DigraphAllTriangles", IsDigraph);
DeclareAttribute("DigraphLargePlanarSubdigraph", IsDigraph);
DeclareAttribute("DIGRAPHS_CompleteMultipartiteDigraphCrossingNumber",
                IsCompleteMultipartiteDigraph);
DeclareAttribute("DIGRAPHS_CompleteBipartiteDigraphCrossingNumber",
                IsCompleteBipartiteDigraph);
DeclareAttribute("CompleteMultipartiteDigraphPartitionSize",
                IsCompleteMultipartiteDigraph);