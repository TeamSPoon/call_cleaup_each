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
      each_call_cleanup/3,             % +Setup, +Goal, +Cleanup
      each_call_catcher_cleanup/4      % +Setup, +Goal, +Catcher, +Cleanup
    ]).

/** <module> Each call cleanup

Call Setup Goal Cleanup *Each* Iteration

@see  https://groups.google.com/forum/#!searchin/comp.lang.prolog/redo_call_cleanup%7Csort:relevance/comp.lang.prolog/frH_4RzMAHg/2bBub5t6AwAJ

*/

:- meta_predicate
        each_call_cleanup(0,0,0),
        each_call_catcher_cleanup(0,0,?,0),
        each_call_cleanup0(*,0,*).


% Writeq/1s a term the user_error and flushes
:- if( \+ current_predicate(dmsg/1)).
dmsg(M):-format(user_error,'~N % dmsg: ~q.~n',[M]),flush_output(user_error).
:- export(dmsg/1).
:- endif.


%!  each_call_cleanup(:Setup, :Goal, :Cleanup).
%!  each_call_catcher_cleanup(:Setup, :Goal, +Catcher, :Cleanup).
%
%   Call Setup before Goal like normal but *also* before each Goal is redone.
%   Also call Cleanup *each* time Goal is finished 

each_call_cleanup(Setup,Goal,Cleanup):- 
 (ground(Setup);ground(Cleanup)),!,
  each_call_cleanup0(Setup,Goal,Cleanup).

each_call_cleanup(Setup,Goal,Cleanup):-
 setup_call_cleanup(
   asserta(('$each_call_cleanup'(Setup):-Cleanup),HND), 
   each_call_cleanup0(pt1(HND),Goal,pt2(HND)),
   erase(HND)).

:- dynamic('$each_call_cleanup'/1).
:- dynamic('$each_call_undo'/2).

pt1(HND) :- clause('$each_call_cleanup'(Setup),Cleanup,HND),call(Setup),asserta('$each_call_undo'(HND,Cleanup)).
pt2(HND) :- retract('$each_call_undo'(HND,Cleanup))->call(Cleanup);true.

each_call_cleanup0(Setup,Goal,Cleanup):-
   \+ \+ '$sig_atomic'(Setup), 
   catch( 
     ((Goal, deterministic(DET)),
       '$sig_atomic'(Cleanup),
         (DET == true -> !
          ; (true;('$sig_atomic'(Setup),fail)))), 
      E, 
      ('$sig_atomic'(Cleanup),throw(E))). 


each_call_catcher_cleanup(Setup, Goal, Catcher, Cleanup):-
   setup_call_catcher_cleanup(true, 
     each_call_cleanup(Setup, Goal, Cleanup), Catcher, true).





end_of_file.


each_call_cleanup(Setup,Goal,Cleanup):- fail,!,
   '$sig_atomic'(Setup), 
   catch( 
     ((Goal, deterministic(DET)),
       '$sig_atomic'(Cleanup),
         (DET == true -> true
          ; (true;('$sig_atomic'(Setup),fail)))), 
      E, 
      ('$sig_atomic'(Cleanup),throw(E))). 