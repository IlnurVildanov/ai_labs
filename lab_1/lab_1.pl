% родился
born(ivan, 1950).
born(olga, 1952).
born(petr, 1975).
born(natalia, 1978).
born(sergey, 1980).
born(elena, 1982).
born(alexey, 2000).
born(maria, 2003).
born(dmitry, 2005).
born(anna, 2007).
born(kirill, 1999).
born(sofia, 2001).
born(viktor, 1970).
born(tatiana, 1973).
born(andrey, 1996).
born(ksenia, 1998).
born(mikhail, 1945).
born(ludmila, 1947).
born(valery, 1968).
born(svetlana, 1972).
born(alina, 2010).
born(egor, 2012).
born(ilya, 2014).
born(oksana, 1985).
born(roman, 1987).
born(denis, 1990).
born(vera, 1992).
born(galina, 1965).
born(fedor, 1962).
born(yulia, 1994).

% умер
died(mikhail, 2015).
died(ludmila, 2020).

% браки
married(ivan, olga, 1970).
married(petr, natalia, 1999).
married(sergey, elena, 2002).
married(viktor, tatiana, 1995).
married(andrey, ksenia, 2020).
married(valery, svetlana, 1990).
married(roman, oksana, 2010).
married(fedor, galina, 1989).

% разводы
divorced(sergey, elena, 2010).
divorced(viktor, tatiana, 2005).

% пол
male(ivan). male(petr). male(sergey). male(alexey).
male(dmitry). male(kirill). male(viktor). male(andrey).
male(mikhail). male(valery). male(egor). male(ilya).
male(roman). male(denis). male(fedor).

female(olga). female(natalia). female(elena). female(maria).
female(anna). female(sofia). female(tatiana). female(ksenia).
female(ludmila). female(svetlana). female(alina). female(oksana).
female(vera). female(galina). female(yulia).


% правило 1 - человек жив в год Y (до года смерти)
alive(P, Y) :-
    born(P, B), Y >= B,
    (died(P, D) -> Y < D ; true).

% правило 2 - симметрия брака
married_sym(A,B,Y) :- married(A,B,Y) ; married(B,A,Y).

% правило 3 - симметрия развода
divorced_sym(A,B,Y) :- divorced(A,B,Y) ; divorced(B,A,Y).

% правило 4 - супруги в год Y (брак есть и не расторгнут к Y)
spouse(A,B,Y) :-
    married_sym(A,B,M),
    Y >= M,
    (divorced_sym(A,B,D) -> Y < D ; true).

% правило 5 - возраст человека в год Y
age(P,Y,A) :-
    born(P,B), A is Y - B,
    (died(P,D) -> Y < D ; true).

% правило 6 - в год рождения ребенка родители состоят в браке
parent(P, C) :-
    born(C, B),
    spouse(M, F, B),
    (P = M ; P = F).

% правило 7 - мать родитель женского пола
mother(M, C) :-
    parent(M, C),
    female(M).

% правило 8 - отец родитель мужского пола
father(F, C) :-
    parent(F, C),
    male(F).

% правило 9 - предок через одно звено
grandparent(GP, GC) :-
    parent(GP, P),
    parent(P, GC).

% правило 10 - бабушка
grandmother(GM, GC) :-
    grandparent(GM, GC),
    female(GM).

% правило 11 - дедушка
grandfather(GF, GC) :-
    grandparent(GF, GC),
    male(GF).

% правило 12 - есть общий родитель, X \= Y
sibling(X, Y) :-
    parent(P, X),
    parent(P, Y),
    X \= Y.

% правило 13 - брат
brother(B, X) :-
    sibling(B, X),
    male(B).

% правило 14 - сестра
sister(S, X) :-
    sibling(S, X),
    female(S).

% правило 15 - дядя
uncle(U, X) :-
    parent(P, X),
    brother(U, P).

% правило 16 - тетя
aunt(A, X) :-
    parent(P, X),
    sister(A, P).

% правило 17 - родитель в конкретный год
parent_in_year(P, C, Y) :-
    parent(P, C),
    alive(P, Y),
    born(C, B), Y >= B.

% правило 18 - сиблинги в год Y оба живы
sibling_in_year(X, Yp, Y) :-
    sibling(X, Yp),
    alive(X, Y),
    alive(Yp, Y).

% правило 19 - дед/бабушка в год Y жив
grandparent_in_year(GP, GC, Y) :-
    grandparent(GP, GC),
    alive(GP, Y),
    born(GC, B), Y >= B.

% правило 20 - дядя в год Y жив
uncle_in_year(U, X, Y) :-
    uncle(U, X),
    alive(U, Y),
    alive(X, Y).

% правило 21 - ребенок C является ребёнком родителя P
child(C, P) :- parent(P, C).

% правило 22 - сын S является ребёнком родителя P
son(S, P) :- child(S, P), male(S).

% правило 23 - дочь D является ребёнком родителя P 
daughter(D, P) :- child(D, P), female(D).

% правило 24 - GC является внуком/внучкой для GP 
grandchild(GC, GP) :- grandparent(GP, GC).

% правило 25 - GS является внуком для GP
grandson(GS, GP) :- grandchild(GS, GP), male(GS).

% правило 26 - GD является внучкой для GP 
granddaughter(GD, GP) :- grandchild(GD, GP), female(GD).

% правило 27 - у ребенка C одновременно известны мать M и отец F
parents_of(C, M, F) :- mother(M, C), father(F, C).

% правило 28 - у X и Y совпадают и мать, и отец
full_sibling(X, Y) :-
    X \= Y,
    parents_of(X, M, F),
    parents_of(Y, M, F).

% правило 29 - есть общий родитель, но не оба сразу
half_sibling(X, Y) :-
    sibling(X, Y),
    \+ full_sibling(X, Y).

% правило 30 - старший (первый по году рождения) ребёнок C у родителя P
eldest_child_of(P, C) :-
    parent(P, C),
    born(C, YC),
    \+ ( parent(P, C2), born(C2, Y2), Y2 < YC ).

% правило 31 - сколько у ребенка родителей
parents_count(C, N) :-
    setof(P, parent(P, C), L), !,
    length(L, N).
parents_count(_, 0).

% правило 32 - сколько детей у родителя P
children_count_of(P, N) :-
    setof(C, parent(P, C), L), !,
    length(L, N).
children_count_of(_, 0).