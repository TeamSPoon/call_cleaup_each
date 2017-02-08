# Call A Goal On *Each* Redo


 Installation using SWI-Prolog 7.1 or later:

    `?- pack_install(each_call_cleanup).`

  or

    `?- pack_install('https://github.com/TeamSPoon/each_call_cleanup.git').`



Source code available and pull requests accepted at
http://github.com/TeamSPoon/each_call_cleanup

```prolog

 / *Example usages: */ 
 
 with_prolog_flag(Flag,Value,Goal):- 
       current_prolog_flag(Flag,Was), 
       each_call_cleanup( 
                   set_prolog_flag(Flag,Value), 
                   Goal, 
                   set_prolog_flag(Flag,Was)). 
 
 

 % notrace/1 that is not like once/1 
  no_trace(Goal):- 
     ( 
     notrace((tracing,notrace)) 
      - 
    ('$leash'(OldL, OldL), 
     '$visible'(OldV, OldV), 
     each_call_cleanup( 
         notrace((visible(-all),leash(-all), 
              leash(+exception),visible(+exception))) 
         Goal, 
         notrace(('$leash'(_, OldL),'$visible'(_, OldV),trace)))) 
    ; 
    Goal). 
            
 
 % Trace non interactively 
 with_trace_non_interactive(Goal):- 
    (   tracing- Undo=trace ; Undo = notrace ), 
 
    '$leash'(OldL, OldL), 
    '$visible'(OldV, OldV), 
    each_call_cleanup( 
         notrace((visible(+all),leash(-all),leash(+exception),trace)), 
         Goal, 
         notrace(('$leash'(_, OldL),'$visible'(_, OldV),Undo))) 


```

[BSD 2-Clause License](LICENSE.md)

Copyright (c) 2017, 
Douglas Miles <logicmoo@gmail.com>
All rights reserved.

