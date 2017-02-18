/* Part of LogicMOO Base Logicmoo Debug Tools
% ===================================================================
% File '$FILENAME.pl'
% Purpose: An Implementation in SWI-Prolog of certain debugging tools
% Maintainer: Douglas Miles
% Contact: $Author: dmiles $@users.sourceforge.net ;
% Version: '$FILENAME.pl' 1.0.0
% Revision: $Revision: 1.1 $
% Revised At:  $Date: 2002/07/11 21:57:28 $
% Licience: LGPL
% ===================================================================
*/
:- module(each_call_cleanup,
   [
      redo_call_cleanup/3,             % +Setup, +Goal, +Cleanup
      each_call_catcher_cleanup/4,     % +Setup, +Goal, ?Catcher, +Cleanup
      each_call_cleanup/3              % +Setup, +Goal, +Cleanup      
    ]).

/** <module> Each call cleanup

Call Setup Goal Cleanup *Each* Iteration

@see  https://groups.google.com/forum/#!searchin/comp.lang.prolog/redo_call_cleanup%7Csort:relevance/comp.lang.prolog/frH_4RzMAHg/2bBub5t6AwAJ

*/

:- meta_predicate
  redo_call_cleanup(0,0,0),
  each_call_catcher_cleanup(0,0,?,0),
  each_call_cleanup(0,0,0).
  

%! redo_call_cleanup(:Setup, :Goal, :Cleanup).
%
% @warn Setup/Cleanup do not share variables.
% If that is needed, use each_call_cleanup/3 

redo_call_cleanup(Setup,Goal,Cleanup):- 
   must_be(nonvar,Setup),must_be(nonvar,Cleanup),
   % \+ \+ 
   '$sig_atomic'(Setup),
   catch( 
     ((Goal, deterministic(DET)),
       '$sig_atomic'(Cleanup),
         (DET == true -> !
          ; (true;('$sig_atomic'(Setup),fail)))), 
      E, 
      ('$sig_atomic'(Cleanup),throw(E))). 


%! each_call_catcher_cleanup(:Setup, :Goal, +Catcher, :Cleanup).
%
%   Call Setup before Goal like normal but *also* before each Goal is redone.
%   Also call Cleanup *each* time Goal is finished
%  @bug Goal does not share variables with Setup/Cleanup Pairs

each_call_catcher_cleanup(Setup, Goal, Catcher, Cleanup):-
   setup_call_catcher_cleanup(true, 
     each_call_cleanup(Setup, Goal, Cleanup), Catcher, true).


%! each_call_cleanup(:Setup, :Goal, :Cleanup).
%
%   Call Setup before Goal like normal but *also* before each Goal is redone.
%   Also call Cleanup *each* time Goal is finished
%  @bug Goal does not share variables with Setup/Cleanup Pairs

each_call_cleanup(Setup,Goal,Cleanup):- 
 ((ground(Setup);ground(Cleanup)) -> 
  redo_call_cleanup(Setup,Goal,Cleanup);
  setup_call_cleanup(
   asserta(('$each_call_cleanup'(Setup):-Cleanup),HND), 
   redo_call_cleanup(pt1(HND),Goal,pt2(HND)),
   (pt2(HND),erase(HND)))).

:- dynamic('$each_call_cleanup'/1).
:- dynamic('$each_call_undo'/2).

pt1(HND) :- 
  clause('$each_call_cleanup'(Setup),Cleanup,HND),!,
    once(Setup),
      asserta('$each_call_undo'(HND,Cleanup)).

pt2(HND) :- 
  retract('$each_call_undo'(HND,Cleanup))
    ->once(Cleanup); true.

:- system:import(each_call_cleanup/3).
:- system:import(redo_call_cleanup/3).
:- system:import(each_call_catcher_cleanup/4).

end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.


:- module(logicmoo_util_scce,
          [ 
            make_nb_setter/2,
            make_nb_setter/4,
            make_nb_setter5/5,
            nb_setargs_1var/5,
            nb_setargs_goals/5,
            scce_orig/3,
            scce_orig2/3,
            scce_test/1,
            scce_idea/3]).

% :- include('logicmoo_util_header.pi').

% :- '$set_source_module'(system).

:- meta_predicate scce_orig(0,0,0).
system:scce_orig(Setup,Goal,Cleanup):-
  must_atomic(Setup),
     catch((
        call((Goal,deterministic(Det),true))
        *->
        (Det == true
          -> (must_atomic(Cleanup),!)
          ; (must_atomic(Cleanup);(must_atomic(Setup),fail)))
     ; (must_atomic(Cleanup),!,fail)),
     E, (ignore(must_atomic(Cleanup)),throw(E))).


:- if(\+ current_predicate(must_atomic/1)).
:- ensure_loaded(logicmoo_util_supp).
:- endif.

:- if(\+ current_predicate(system:nop/1)).
:- system:ensure_loaded(system:logicmoo_util_supp).
:- endif.


:- meta_predicate scce_orig2(0,0,0).
system:scce_orig2(Setup,Goal,Cleanup):- 
  setup_call_cleanup(Setup, 
    (call((Goal,deterministic(Det),true))
       *-> (Det == true -> ! ; 
        (once(Cleanup);(once(Setup),fail))) ; (!,fail)) ,Cleanup).

make_nb_setter(Term,G):-make_nb_setter(Term,_Copy,nb_setarg,G).

make_nb_setter(Term,Next,Pred,G):-
 cnotrace((  copy_term(Term,Next),
  term_variables(Term,Vs),
  term_variables(Next,CVs),
  make_nb_setter5(Vs,CVs,Pred,Term,G))).

make_nb_setter5(Vs,CVs,Pred, Term,maplist(call,SubGs)):-
       cnotrace(( maplist(nb_setargs_1var(Term,Pred), Vs,CVs, SubGs))).

nb_setargs_1var(Term,Pred, X, Y, maplist(call,NBSetargClosure)):-
        bagof(How, nb_setargs_goals(X,Y,Pred, Term,How),NBSetargClosure).

nb_setargs_goals(X,Y,Pred, Term, How) :-
        compound(Term),
        arg(N, Term, Arg),
        (Arg ==X -> How=call(Pred,N,Term,Y) ;
           nb_setargs_goals(X,Y,Pred,Arg,How)).


