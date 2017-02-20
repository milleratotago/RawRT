Rem This batch file is to be used before/after commits and pushes.
Rem
Rem Step 1: Check whether any files from elsewhere have been updated here.
Rem   If so, reconcile any differences.
Rem
Rem Step 2: Use dirc to remove the elsewhere files from here
Rem
Rem Step 3: Use this MATLAB function to generate a set of dirc commands for Step 4:
Rem   RequiredFileList = mFilesNeeded('Demo*.m');
Rem   NOT WRITTEN RequiredDircs = ???(RequiredFileList);
Rem   Copy the resulting dirc commands into this file at step 4.
Rem 
Rem Step 4: Run dirc to copy the needed files here.
Rem
Rem Step 5: git status, commit, merge, commit, push
Rem
Rem Step 6: Same as step 2

goto Step4

Rem This file copies files from other projects into this directory:
Rem Note it is currently copying some files from Cupid

:Step1
dirc \Matlab\Tools\ExtractNameVal\*.m . list2 newer2
dirc \Matlab\Tools\GLM\*.m .  list2 newer2
dirc \Matlab\Tools\JOM\*.m .  list2 newer2
dirc \Matlab\Tools\Net\*.m .  list2 newer2
dirc \Matlab\Cupid\*.m .  list2 newer2
goto end

:Step2
dirc \Matlab\Tools\ExtractNameVal\*.m . del2 older2 matches
dirc \Matlab\Tools\GLM\*.m .  del2 older2 matches
dirc \Matlab\Tools\JOM\*.m .  del2 older2 matches
dirc \Matlab\Tools\Net\*.m .  del2 older2 matches
dirc \Matlab\Cupid\*.m .  del2 older2 matches
goto end

:Step3
Rem Run MATLAB
goto end

:Step4
dirc P:\Matlab\cupid\AnyRealToGT.m . copy1 only1 newer1
dirc P:\Matlab\cupid\ConstantC.m . copy1 only1 newer1
dirc P:\Matlab\cupid\GTToAnyReal.m . copy1 only1 newer1
dirc P:\Matlab\cupid\Normal.m . copy1 only1 newer1
dirc P:\Matlab\cupid\dContinuous.m . copy1 only1 newer1
dirc P:\Matlab\cupid\dGeneric.m . copy1 only1 newer1
dirc P:\Matlab\cupid\fminsearcharb.m . copy1 only1 newer1
dirc P:\Matlab\cupid\ifelse.m . copy1 only1 newer1
dirc P:\Matlab\cupid\obscenmoment.m . copy1 only1 newer1
dirc P:\Matlab\tools\ExtractNameVal\EnsureCell.m . copy1 only1 newer1
dirc P:\Matlab\tools\ExtractNameVal\ExtractName.m . copy1 only1 newer1
dirc P:\Matlab\tools\ExtractNameVal\ExtractNameVal.m . copy1 only1 newer1
dirc P:\Matlab\tools\ExtractNameVal\ExtractNameVali.m . copy1 only1 newer1
dirc P:\Matlab\tools\ExtractNameVal\ExtractNamei.m . copy1 only1 newer1
dirc P:\Matlab\tools\GLM\AnovaStructure.m . copy1 only1 newer1
dirc P:\Matlab\tools\GLM\Decompose.m . copy1 only1 newer1
dirc P:\Matlab\tools\JOM\iswholenumber.m . copy1 only1 newer1
goto end

:Step5
Rem run git
goto end

:Step6
Rem Repeat step2
goto end


:end
