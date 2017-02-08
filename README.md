# Call A Goal On *Each* Redo


 Installation using SWI-Prolog 7.1 or later:

    `?- pack_install(each_call_cleanup).`

  or

    `?- pack_install('https://github.com/TeamSPoon/each_call_cleanup.git').`



Source code available and pull requests accepted at
http://github.com/TeamSPoon/each_call_cleanup

Example usages: 

```prolog

 
 with_prolog_flag(Flag,Value,Goal):- 
    (current_prolog_flag(Flag,Was)-> Cleanup = set_prolog_flag(Flag,Was); true),
     each_call_cleanup( 
	 set_prolog_flag(Flag,Value), 
	  Goal, 
	   Cleanup). 
 
 

 % notrace/1 that is not like once/1 
 no_trace(Goal):- 
    tracing ->
      each_call_cleanup(notrace,Goal,trace);
      Goal.
    
            
 

 % Trace non interactively 
 rtrace(Goal):- 
    ( tracing-> Undo=trace ; Undo = notrace ), 
    '$leash'(OldL, OldL), '$visible'(OldV, OldV), 
    each_call_cleanup( 
         (notrace,visible(+all),leash(-all),leash(+exception),trace), 
         Goal,
         (notrace,'$leash'(_, OldL),'$visible'(_, OldV),Undo)).


```

[BSD 2-Clause License](LICENSE.md)

Copyright (c) 2017, 
Douglas Miles <logicmoo@gmail.com>
All rights reserved.

