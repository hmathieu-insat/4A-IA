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
	heuristique(S0, H0),
	G0 is 0,
	F0 is (G0 + H0),
	
	empty(Pfx), empty(Pux), empty(Q),
	
	insert(([[F0, H0, G0], S0]), Pfx, Pf), 
	insert([S0, [F0, H0, G0], nil, nil], Pux, Pu),
	aetoile(Pf, Pu, Q).


%*******************************************************************************

aetoile(Pf, Pu, Qu) :-
	empty(Pf), empty(Pu), write("PAS de solution : l'etat final n'est pas atteignable").

aetoile(Pf, Pu, Qu) :-
	suppress_min([[_,_,G], S], Pf, X), final_state(S), 
	affiche_solution(S).
	
aetoile(Pf, Pu, Q) :-
	suppress_min(U, Pf, Pf_new), suppress(U, Pu, Pu_new),
	expand(U, Slist),
	loop_successors(Slist, Pu_new, Pf_new, Pu_n, Pf_n),
	insert(U, Q, Q_new),
	aetoile(Pf_n, Pf_n, Q_new).

expand(U, Slist) :-
	findall(S2, rule(X, 1, U, S2), Successors),
	
	

% loop_successors
	
	% Tests unitaires
% :- empty(FinA), final_state(Fin), insert([[0,0,0] ,Fin] , FinA, Finx), aetoile(Finx, nil, nil).
% :- empty(FinA), initial_state(Fin), insert([[0,0,0] ,Fin] , FinA, Finx), aetoile(Finx, nil, nil).

   