	/*********************************
	DESCRIPTION DU JEU DU TIC-TAC-TOE
	*********************************/

	/*
	Une situation est decrite par une matrice 3x3.
	Chaque case est soit un emplacement libre (Variable LIBRE), soit contient le symbole d'un des 2 joueurs (o ou x)

	Contrairement a la convention du tp precedent, pour modeliser une case libre
	dans une matrice on n'utilise pas une constante speciahttps://swish.swi-prolog.org/#tabbed-tab-1le (ex : nil, 'vide', 'libre','inoccupee' ...);
	On utilise plut�t un identificateur de variable, qui n'est pas unifiee (ex : X, A, ... ou _) .
	La situation initiale est une "matrice" 3x3 (liste de 3 listes de 3 termes chacune)
	o� chaque terme est une variable libre.
	Chaque coup d'un des 2 joureurs consiste a donner une valeur (symbole x ou o) a une case libre de la grille
	et non a deplacer des symboles deja presents sur la grille.

	Pour placer un symbole dans une grille S1, il suffit d'unifier une des variables encore libres de la matrice S1,
	soit en ecrivant directement Case=o ou Case=x, ou bien en accedant a cette case avec les predicats member, nth1, ...
	La grille S1 a change d'etat, mais on n'a pas besoin de 2 arguments representant la grille avant et apres le coup,
	un seul suffit.
	Ainsi si on joue un coup en S, S perd une variable libre, mais peut continuer a s'appeler S (on n'a pas besoin de la designer
	par un nouvel identificateur).
	*/

situation_initiale([ [_,_,_],
                     [_,_,_],
                     [_,_,_] ]).

situation_gagnante([x,x,x],[o,o,_],[o,_,_]).

situation_nulle([o,x,o],[x,o,x],[x,o,x]).

situation_heuristique([x,_,x],[o,x,o],[o,_,o]).

situation_test([o,x,_],[x,_,_],[_,_,_]).
	% Convention (arbitraire) : c'est x qui commence

joueur_initial(x).


	% Definition de la relation adversaire/2

adversaire(x,o).
adversaire(o,x).


	/****************************************************
	 DEFINIR ICI a l'aide du predicat ground/1 comment
	 reconnaitre une situation terminale dans laquelle il
	 n'y a aucun emplacement libre : aucun joueur ne peut
	 continuer a jouer (quel qu'il soit).
	 ****************************************************/

situation_terminale(_Joueur, Situation) :-	 ground(Situation).


	/***************************
	DEFINITIONS D'UN ALIGNEMENT
	***************************/

alignement(L, Matrix) :- ligne(    L,Matrix).
alignement(C, Matrix) :- colonne(  C,Matrix).
alignement(D, Matrix) :- diagonale(D,Matrix).

	/********************************************
	 DEFINIR ICI chaque type d'alignement maximal
 	 existant dans une matrice carree NxN.
	 ********************************************/

ligne(L, M) :- member(L,M).

colonne(C,M) :- colonne2(_,C,M).
colonne2(_,[],[]).
colonne2(N, [E|C],[L|M]) :- nth1(N,L,E), colonne2(N,C,M).

	/* Definition de la relation liant une diagonale D a la matrice M dans laquelle elle se trouve.
		il y en a 2 sortes de diagonales dans une matrice carree(https://fr.wikipedia.org/wiki/Diagonale) :
		- la premiere diagonale (principale)  : (A I)
		- la seconde diagonale                : (Z R)
		A . . . . . . . Z
		. \ . . . . . / .
		. . \ . . . / . .
		. . . \ . / . . .
		. . . . X . . .
		. . . / . \ . . .
		. . / . . . \ . .
		. / . . . . . \ .
		R . . . . . . . I
	*/

diagonale(D, M) :-
	premiere_diag(1,D,M).


diagonale(D, M) :-
	seconde_diag(3,D,M).


premiere_diag(_,[],[]).
premiere_diag(K,[E|D],[Ligne|M]) :-
	nth1(K,Ligne,E),
	K1 is K+1,
	premiere_diag(K1,D,M).

seconde_diag(_,[],[]).
seconde_diag(K, [E|D], [Ligne|M]) :-
	nth1(K, Ligne, E),
	K1 is K-1,
	seconde_diag(K1,D,M).



	/*****************************
	 DEFINITION D'UN ALIGNEMENT
	 POSSIBLE POUR UN JOUEUR DONNE
	 *****************************/

possible([X|L], J) :- unifiable(X,J), possible(L,J).
possible(  [],  _).

	/* Attention
	il faut juste verifier le caractere unifiable
	de chaque emplacement de la liste, mais il ne
	faut pas realiser l'unification.
	*/

unifiable(X,J) :- not(not(X=J)).

	/**********************************
	 DEFINITION D'UN ALIGNEMENT GAGNANT
	 OU PERDANT POUR UN JOUEUR DONNE J
	 **********************************/
	/*
	Un alignement gagnant pour J est un alignement
possible pour J qui n'a aucun element encore libre.
	*/

	/*
	Remarque : le predicat ground(X) permet de verifier qu'un terme
	prolog quelconque ne contient aucune partie variable (libre).
	exemples :
		?- ground(Var).
		no
		?- ground([1,2]).
		yes
		?- ground(toto(nil)).
		yes
		?- ground( [1, toto(nil), foo(a,B,c)] ).
		no
	*/

	/* Un alignement perdant pour J est un alignement gagnant pour son adversaire. */


alignement_gagnant(Ali, J) :- ground(Ali), possible(Ali, J).

alignement_perdant(Ali, J) :- adversaire(J,A), alignement_gagnant(Ali,A).


	/* ****************************
	DEFINITION D'UN ETAT SUCCESSEUR
	****************************** */

	/*
	Il faut definir quelle operation subit la matrice
	M representant l'Etat courant
	lorsqu'un joueur J joue en coordonnees [L,C]
	*/

successeur(J, Etat,[L,C]) :- nth1(L, Etat, Lig), nth1(C, Lig, J), var(Elem), Elem = J.



	/**************************************
   	 EVALUATION HEURISTIQUE D'UNE SITUATION
  	 **************************************/

	/*
	1/ l'heuristique est +infini si la situation J est gagnante pour J
	2/ l'heuristique est -infini si la situation J est perdante pour J
	3/ sinon, on fait la difference entre :
	   le nombre d'alignements possibles pour J
	moins
 	   le nombre d'alignements possibles pour l'adversaire de J
*/

ali_possible(Situation, Ali, J) :- alignement(Ali, Situation), possible(Ali,J).

heuristique(J,Situation,H) :-		% cas 1
   H = 10000,				% grand nombre approximant +infini
   alignement(Alig,Situation),
   alignement_gagnant(Alig,J), !.

heuristique(J,Situation,H) :-		% cas 2
   H = -10000,				% grand nombre approximant -infini
   alignement(Alig,Situation),
   alignement_perdant(Alig,J), !.

heuristique(J,Situation,H) :-
	findall(Ali,ali_possible(Situation, Ali, J),ListAlign),
	length(ListAlign, N1),
	adversaire(J,A),
	findall(Ali, ali_possible(Situation, Ali, A), ListAlignAdv),
	length(ListAlignAdv, N2),
	H is N1-N2.

% Tests unitaires

vic_x([[x,x,x], [_,_,_], [_,_,_]]).
loss_x([[o,o,o], [_,_,_], [_,_,_]]).
draw([[o,x,o],
	[x,o,o],
	[x,o,x]]).

:- vic_x(S), heuristique(x, S, H), H = 10000.
:- loss_x(S), heuristique(x, S, H), H = -10000.
:- draw(S), heuristique(x, S, H), H = 0.

