%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme
 
- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu
 
   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).
   
   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de fa�on synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Ps (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f 
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Ps
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche   
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************

main :-
	% initialisations Pf, Pu et Q 
	initial_state(S0),
	write("Pour un etat initial : "), write(S0), nl,
	heuristique(S0, H0),
	G0 is 0,			
	F0 is (G0 + H0),
	
	empty(Pfx), empty(Pux), empty(Q),	% Création des 3 AVLs vides
	
	insert(([[F0, H0, G0], S0]), Pfx, Pf), 
	insert([S0, [F0, H0, G0], nil, nil], Pux, Pu),
	
	aetoile(Pf, Pu, Q).


%*******************************************************************************

aetoile(Pf, Pu, _) :-
	empty(Pf), empty(Pu), write("PAS de solution : l'etat final n'est pas atteignable"),!.

aetoile(Pf, Pu, Q) :-
	suppress_min([[_,_,_], S], Pf, _), final_state(S),
	suppress([S, _, Padre, Act], Pu, _),
	insert([S, _, Padre, Act], Q, Q_new),
	write("La solution est :"), nl,
	
	affiche_solution(S, Q_new).
	
aetoile(Pf, Pu, Q) :-
	suppress_min([[F, H, G], U], Pf, Pf_new), 

	suppress([U, Val, Pere, Action], Pu, Pu_new),
	expand([[F, H, G], U], Slist),	% Le prédicat expand renvoie la liste des successeurs de U et leur évaluation
	loop_successors(Slist, Q, Pu_new, Pf_new, Pu_n, Pf_n, U), % On itère sur les successeurs et on les traite
	insert([U, Val, Pere, Action], Q, Q_new),
	aetoile(Pf_n, Pu_n, Q_new).


expand([[_, _, G], U], Slist) :-
	findall([[Fs, Hs, Gs], S2], (rule(_, Cout, U, S2), Gs is G + Cout, heuristique(S2, Hs), Fs is Gs + Hs), Slist).


loop_successors([], _, Pu, Pf, Pu_new, Pf_new, _) :- 
	Pu_new = Pu, Pf_new = Pf.
	
loop_successors([ [_, S] | TL], Q, Pu, Pf, Pu_new, Pf_new, Pere) :-
	belongs([S,_,_,_], Q),
	loop_successors(TL, Q, Pu, Pf, Pu_new, Pf_new, Pere).

loop_successors([ [Eval, S] | TL], Q, Pu, Pf, Pu_new, Pf_new, Pere) :-
	
	suppress([S, _, _ , _], Pu, Pun),	% Le prédicat échoue si S n'est pas dans Pu
	suppress([EvalF, S], Pf, Pfn),		% Permet de récupérer l'évaluation correspondante dans Pf
	( Eval @< EvalF ->
		insert([Eval, S], Pfn, Pf2),
		insert([Eval, S], Pun, Pu2),
		loop_successors(TL, Q, Pu2, Pf2, Pu_new, Pf_new, Pere)
	;

		loop_successors(TL, Q, Pu, Pf, Pu_new, Pf_new, Pere)
	).
	
loop_successors([ [Eval, S] | TL], Q, Pu, Pf, Pu_new, Pf_new, Pere) :-
	rule(X, _, Pere, S),
	insert([Eval, S], Pf, Pf2),
	insert( [S, Eval, Pere, X], Pu, Pu2),
	loop_successors(TL, Q, Pu2, Pf2, Pu_new, Pf_new, Pere).

affiche_solution(S, _) :-
	initial_state(S).

affiche_solution(S, Q) :-
	suppress([S, _, Padre, Act], Q, Q_new),
	affiche_solution(Padre, Q_new),
	write(Act), nl.

affiche_solution(_, _) :-
	write("protection contre boucle infinie en cas d'erreur"), nl.


	
	% Tests unitaires
% :- empty(FinA), final_state(Fin), insert([[0,0,0] ,Fin] , FinA, Finx), aetoile(Finx, nil, nil).
% :- empty(FinA), initial_state(Fin), insert([[0,0,0] ,Fin] , FinA, Finx), aetoile(Finx, nil, nil).

   