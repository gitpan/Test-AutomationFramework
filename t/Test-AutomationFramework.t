
#########################

use Test::AutomationFramework;

my $cmd; my $rst; my $loaded = 1; my $tcName ; my $tcDesc ;  my $tcOp;
my $taf= 'c:/_TAF/taf.pl';
########################## End of black magic.
my $TAF_ = new Test::AutomationFramework; $TAF_->help(); undef $TAF_;

	&test1_pre(); 
 	&test1_verify(); 
      	&test1_verifyB(); 
      	&test1_post(); 

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Test-AutomationFramework.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More ; 
#BEGIN { use_ok('Test::AutomationFramework') };
#BEGIN { use_ok('Test::AutomationFramework') };

#########################

use Test::AutomationFramework;
my $TAF = new Test::AutomationFramework;

$TAF->processTCs("pr2Screen=0");
# $TAF->processTCs("runRegression=1");
########################

# use Test::More;
# BEGIN { $| = 1; print "1..last_test_to_print\n"; }
#END {print "not ok 1\n" unless $loaded;}

# use AutomationFramework;
# my $tcName ; my $tcDesc ; 
# my $TAF = new AutomationFramework;

########################## End of black magic.
&regression4GlobalVars(); 
&regression4Property(); 
&regression4TC();
done_testing(122);
sub regression4GlobalVars {
	$tcDesc = "Global Variable Managements";
	$TAF->help();
 	like ($TAF->getGlobalVars(), qr/_testSuit_/, $tcDesc.": get Global Variables");
 	like ($TAF->getGlobalVars(), qr/c:/, $tcDesc.": get Global Variables");
	$TAF->setGlobalVars("SvrDrive=d:;SvrProjName=_testProj2_");
	like ($TAF->getGlobalVars(), qr/_testProj2_/, $tcDesc.": set lobal Variables");
	like ($TAF->getGlobalVars(), qr/d:/, $tcDesc.": set Global Variables");
	$TAF->setGlobalVars("SvrDrive=c:/_TAF;SvrProjName=_testSuit_");
 	like ($TAF->getGlobalVars(), qr/_testSuit_/, $tcDesc.": get Global Variables - postProcess");
 	like ($TAF->getGlobalVars(), qr/c:/, $tcDesc.": get Global Variables - postProcess");
}

sub regression4Property {
# 	Regression Test of TC Property Create|List|
	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (add=prop:value) ";
	# $TAF->setGlobalVars("pr2Screen=0;");
	$TAF->processTCs("pr2Screen=0");
	$TAF->processTCs("printVars");
    	$TAF->processTC("delete=$tcName"); 
	$TAF->processTCs("printVars");
	$TAF->processTC("create=$tcName"); 
	$TAF->processTCs("printVars");
 #	------ add Property 
 	$TAF->processProperty($tcName,"add=addedProperty1:propVal1");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal1");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal2");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal3");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal4");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal5");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal6");
 	$TAF->processProperty($tcName,"add=addedProperty3:propVal3");
 	$TAF->processProperty($tcName,"add=addedProperty4:propVal4");
  	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (add=addedPropertyN:propValueN) - like";
	like ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal1/, $tcDesc.": list all Properties");
  	like ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal6/, $tcDesc.": list all Properties");
  	like ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal3/, $tcDesc.": list all Properties");
  #	------ get Property 
  	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=prop;latest) - like";
  	like ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal1/, $tcDesc.": list all Properties");
  	like ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal6/, $tcDesc.": list all Properties");
  	like ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal3/, $tcDesc.": list all Properties");
  	unlike ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal2/, $tcDesc.": list all Properties");
  	unlike ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal5/, $tcDesc.": list all Properties");
 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=prop;value) - like";
 	like ($TAF->processProperty($tcName,"get=added;value"), qr/propVal1/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;value"), qr/propVal2/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;value"), qr/propVal3/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;value"), qr/propVal4/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;value"), qr/propVal5/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;value"), qr/propVal6/, $tcDesc.": list all Properties");
 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=prop;value) - unlike";
 	unlike ($TAF->processProperty($tcName,"get=added;value"), qr/addedProperty1/, $tcDesc.": list all Properties");
 	unlike ($TAF->processProperty($tcName,"get=added;value"), qr/addedProperty2/, $tcDesc.": list all Properties");
 	unlike ($TAF->processProperty($tcName,"get=added;value"), qr/addedProperty3/, $tcDesc.": list all Properties");
 	unlike ($TAF->processProperty($tcName,"get=added;value"), qr/addedProperty4/, $tcDesc.": list all Properties");
 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=prop;history) ";
 	like ($TAF->processProperty($tcName,"get=added;history"), qr/addedProperty1\s*=\s*propVal1/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;history"), qr/addedProperty2\s*=\s*propVal1/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;history"), qr/addedProperty2\s*=\s*propVal2/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;history"), qr/addedProperty2\s*=\s*propVal3/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;history"), qr/addedProperty2\s*=\s*propVal4/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;history"), qr/addedProperty3\s*=\s*propVal3/, $tcDesc.": list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;history"), qr/addedProperty4\s*=\s*propVal4/, $tcDesc.": list all Properties");
 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=prop:value) ";
 	like ($TAF->processProperty($tcName,"get=.*"), qr/addedProperty3/, "$tcDesc: list all Properties");
 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=prop:value) ";
 	like ($TAF->processProperty($tcName,"get=.*"), qr/addedProperty1/, "$tcDesc: list all Properties");
 	like ($TAF->processProperty($tcName,"get=.*"), qr/addedProperty2/, "$tcDesc: list all Properties");
 	like ($TAF->processProperty($tcName,"get=.*"), qr/addedProperty3/, "$tcDesc: list all Properties");
 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=) ";
 	like ($TAF->processProperty($tcName,"get="), qr/propVal1/, "$tcDesc: list all Properties");
 	like ($TAF->processProperty($tcName,"get="), qr/propVal4/, "$tcDesc: list all Properties");
 	like ($TAF->processProperty($tcName,"get="), qr/propVal3/, "$tcDesc: list all Properties");
 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=prop) pr name/value";
 	like ($TAF->processProperty($tcName,"get=added"), qr/addedProperty1/, "$tcDesc: list all Properties");
 	like ($TAF->processProperty($tcName,"get=added"), qr/addedProperty2/, "$tcDesc: list all Properties");
 	like ($TAF->processProperty($tcName,"get=added"), qr/addedProperty3/, "$tcDesc: list all Properties");
 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=prop) unlike ";
 
 	unlike ($TAF->processProperty($tcName,"get=added;value"), qr/addedProperty1/, "$tcDesc: list all Properties");
 	unlike ($TAF->processProperty($tcName,"get=added;value"), qr/addedProperty2/, "$tcDesc: list all Properties");
 	unlike ($TAF->processProperty($tcName,"get=added;value"), qr/addedProperty3/, "$tcDesc: list all Properties");
 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (get=prop) like ";
 	like ($TAF->processProperty($tcName,"get=added;value"), qr/propVal1/, "$tcDesc: list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;value"), qr/propVal4/, "$tcDesc: list all Properties");
 	like ($TAF->processProperty($tcName,"get=added;value"), qr/propVal3/, "$tcDesc: list all Properties");
 
 #	------ del Property 
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (delete=addedProperty1)";
 	$TAF->processProperty($tcName,"del=addedProperty1");
 	unlike ($TAF->processProperty($tcName,"get=added;history"), qr/addedProperty1/, $tcDesc.": delete Property");
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (delete=addedProperty2)";
 	$TAF->processProperty($tcName,"del=addedProperty2");
 	unlike ($TAF->processProperty($tcName,"get=added;history"), qr/addedProperty2/, $tcDesc.": delete Property");
 
 	$TAF->processProperty($tcName,"add=addedProperty1:propVal1");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal1");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal2");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal3");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal4");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal5");
 	$TAF->processProperty($tcName,"add=addedProperty2:propVal6");
 	$TAF->processProperty($tcName,"add=addedProperty3:propVal3");
 	$TAF->processProperty($tcName,"add=addedProperty4:propVal4");$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (modify=prop:value) - like";
 
 #	------ modify Property 
 	like ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal1/, $tcDesc.": processProperty modify property");
 	like ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal6/, $tcDesc.": processProperty modify property");
 	$TAF->processProperty($tcName,"modify=addedProperty1:modifiedProperty1");
 	$TAF->processProperty($tcName,"modify=addedProperty2:modifiedProperty2");
 	like ($TAF->processProperty($tcName,"get=added;latest"), qr/modifiedProperty1/, $tcDesc.": processProperty modify Property");
 	like ($TAF->processProperty($tcName,"get=added;latest"), qr/modifiedProperty2/, $tcDesc.": processProperty modify Property");
 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (modify=prop:value) - unlike";
 	unlike ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal1/, $tcDesc.": processProperty modify Property");
 	unlike ($TAF->processProperty($tcName,"get=added;latest"), qr/propVal6/, $tcDesc.": processProperty modify Property");
	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processProperty (add=prop:value) ";
	$TAF->processTC("delete=$tcName"); 
}

sub regression4TC {
#	Regression Test of Test Case Create|delete|detect
	$TAF->setGlobalVars("notUsegetTCName=0");  ### The variable set the TAF for testing InternalMethods 

 	$tcName = "TC_tcA1"; $tcDesc = sprintf "%-40s","processTestCase (tc creation)";
	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
   	like ($TAF->processTC("create=$tcName"), qr/$tcName\s+is\s+created/,  $tcDesc.': preProcessor'); 
   	like ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+1/,  $tcDesc.': preProcessor'); 
#	------ create Automated Test Case - retrun PASS
	$tcName = "TC_tcA2"; $tcDesc = sprintf "%-40s","processTestCase (failed tc creation)";
   	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+1/,  $tcDesc.': preProcessor'); 
      	$TAF->processTC("create=$tcName"); 
   	like ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
	$TAF->processTC("exec=$tcName"); 
	like ($TAF->processProperty($tcName,"get=tcRunResult;latest"), qr/pass/, $tcDesc.": TC return \'pass\'") ;
   	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+1/,  $tcDesc.': preProcessor'); 

#	todo ------ create Automated Test Case - retrun PASS history 

#	------ create Automated Test Case - return FAIL

	$tcName = "TC_tcA3"; $tcDesc = sprintf "%-40s","processTestCase (failed tc creation)";
   	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
      	$TAF->processTC("create=$tcName;FailedTC"); 
   	like ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
	$TAF->processTC("exec=$tcName"); 
	like ($TAF->processProperty($tcName,"get=tcRunResult;latest"), qr/fail/, $tcDesc.": TC return \'fail\'") ;
   	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 

#	------ create Automated Test Case - Performance Test return seconds
	$tcName = "TC_tcA4"; $tcDesc = sprintf "%-40s","processTestCase (performance tc creation)";
   	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
      	$TAF->processTC("create=$tcName;performanceTC"); 
   	like ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
	$TAF->processTC("exec=$tcName"); 
	like ($TAF->processProperty($tcName,"get=tcRunResult;latest"), qr/\d+[\.\d+]?/, $tcDesc.": TC return \'float for performance TC\'") ;
   	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': postProcessor'); 

	
#	------ create Automated Test Case - with Log file
	$tcName = "TC_tcA5"; $tcDesc = sprintf "%-40s","processTestCase (tc /w log creation)";
   	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
      	$TAF->processTC("create=$tcName;genLog"); 
   	like ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
	$TAF->processTC("exec=$tcName"); 
 	like ($TAF->processTC( "getLogName=$tcName"), qr/_tcLogAppend/, $tcDesc.":verification of log file creation"); 
   	$TAF->processTC("delete=$tcName"); 
 	unlike ($TAF->processTC( "getLogName=$tcName"), qr/_tcLogAppend/, $tcDesc.":verification of log file creation"); 
#	------ overwrite Automated Test Case 
	$tcName = "TC_tcA6"; $tcDesc = sprintf "%-40s","processTestCase (tc overwrite)";
   	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
      	$TAF->processTC("create=$tcName"); 
   	like ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 
	$TAF->processTC("exec=$tcName"); 
	$TAF->processTC("create=$tcName;FailedTC"); 
	like ($TAF->processProperty($tcName,"get=tcRunResult;latest"), qr/pass/, $tcDesc.": TC overrite fails - Expected") ;
      	$TAF->processTC("create=$tcName;FailedTC,overwrite"); 
	$TAF->processTC("exec=$tcName"); 
	like ($TAF->processProperty($tcName,"get=tcRunResult;latest"), qr/fail/, $tcDesc.": TC overrite succeed") ;
   	$TAF->processTC("delete=$tcName"); 
   	unlike ($TAF->processTC("detect=$tcName"), qr/$tcName\s+exists/,  $tcDesc.': preProcessor'); 

}





	sub test1_verifyB { # Create TestSuit with directory struc 
	  $tcDesc = "list TCs by TCNamePattern  Boundary Testing";
 	  $cmd =  $taf. ' ts=_testsuitB_/subTestSuit;create=testcase/subtestcase/overwrite'; $rst = `$cmd`; #overwrite is a keyword
 	  like ($rst, qr/is created/, $tcDesc.": processTCs TCnamePattern");

 	  $cmd =  $taf. ' ts=_testsuitB_/subTestSuit;detect=testcase/subtestcase'; $rst = `$cmd`;
 	  like ($rst, qr/\bexists\b/, $tcDesc.": processTCs TCnamePattern");

	  $cmd =  $taf. ' ts=_testsuitB_/subTestSuit;delete=testcase/subtestcase'; $rst = `$cmd`; 
	  like ($rst, qr/is deleted/, $tcDesc.": processTCs TCnamePattern");

	  $cmd =  $taf. ' ts=_testsuitB_/subTestSuit;detect=testcase/subtestcase'; $rst = `$cmd`;
	  like ($rst, qr/\btestcase\b/, $tcDesc.": processTCs TCnamePattern");
	  unlike ($rst, qr/\bsubtestcase\b/, $tcDesc.": processTCs TCnamePattern");


	}
	sub test1_verify { # TCName filter 
			   # tcName is for <Glob/tcName> which is different from PropertyName and PropertyValue
	$tcDesc = "TC_Name_Filter Test by TCNamePattern";
	# $cmd =  $taf. ' TCNamePattern=test.*;tcOp=list;pr2Screen=1;printVars -processTC execAll'; $rst = `$cmd`; 
	#  $cmd =  $taf. ' TCNamePattern=test.*;tcOp=list;pr2Screen=1;printVars'; $rst = `$cmd`; 
	  $cmd =  $taf. ' TCNamePattern=test.*;tcOp=list'; $rst = `$cmd`; 
	 like ($rst, qr/\btestcase\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase1\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase2\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase3\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase4\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase_1\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase_2\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase_3\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase_4\b/, $tcDesc.": processTCs TCnamePattern");
	 # $cmd =  $taf. ' -processTCs TCNamePattern=test*1*;tcOp=list;pr2Screen=1 -processTC execAll'; $rst = `$cmd`; 
	  $cmd =  $taf. ' TCNamePattern=test.*1.*;tcOp=list'; $rst = `$cmd`; 
	 unlike ($rst, qr/\btestcase\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase1\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase2\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase3\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase4\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase_1\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase_2\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase_3\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase_4\b/, $tcDesc.": processTCs TCnamePattern");

	 # $cmd =  $taf. ' -processTCs TCNamePattern=test*[1]*;tcOp=list;pr2Screen=1 -processTC execAll'; $rst = `$cmd`; 
	  $cmd =  $taf. ' TCNamePattern=test.*[1].*;tcOp=list'; $rst = `$cmd`; 
	 unlike ($rst, qr/\btestcase\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase1\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase2\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase3\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase4\b/, $tcDesc.": processTCs TCnamePattern");
	 like ($rst, qr/\btestcase_1\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase_2\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase_3\b/, $tcDesc.": processTCs TCnamePattern");
	 unlike ($rst, qr/\btestcase_4\b/, $tcDesc.": processTCs TCnamePattern");
	$cmd =  $taf. ' -processTCs TCNamePattern=test*[1\|2]*;tcOp=list -processTC execAll'; $rst = `$cmd`;
	 like ($rst, qr/^\s*$/, $tcDesc.": processTCs TCnamePattern - NEGATIVE TEST");

	}
sub test1_pre { # create - Test Bed 
	# $cmd = "perl -MTest::AutomationFramework -e \"help\""; `$cmd`;
	$cmd = "perl -MTest::AutomationFramework -e \"prDriver\""; `$cmd`;
	# $cmd =  $taf. ' -processTCs printVars '; $rst = `$cmd`; print $rst."\n";
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;create=testcase; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;create=testcase1; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;create=testcase2; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;create=testcase3; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;create=testcase4; '; $rst = `$cmd`; print $rst;

	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;create=testcase_1; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;create=testcase_2; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;create=testcase_3; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;create=testcase_4; '; $rst = `$cmd`; print $rst;

	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;tcnamepattern=testcase\b;tcop=exec; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;tcnamepattern=testcase1\b;tcop=exec; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;tcnamepattern=testcase2\b;tcop=exec; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;tcnamepattern=testcase3\b;tcop=exec; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;tcnamepattern=testcase4\b;tcop=exec; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;tcnamepattern=testcase_1\b;tcop=exec; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;tcnamepattern=testcase_2\b;tcop=exec; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;tcnamepattern=testcase_3\b;tcop=exec; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;tcnamepattern=testcase_4\b;tcop=exec; '; $rst = `$cmd`; print $rst;

	}

sub test1_post { # delete - Test Bed
	$tcDesc = "delete TCs ";

	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;delete=testcase; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;delete=testcase1; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;delete=testcase2; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;delete=testcase3; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;delete=testcase4; '; $rst = `$cmd`; print $rst;

	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;delete=testcase_1; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;delete=testcase_2; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;delete=testcase_3; '; $rst = `$cmd`; print $rst;
	$cmd =  $taf. ' ts=_testsuit_;pr2Screen=0;delete=testcase_4; '; $rst = `$cmd`; print $rst;

	$cmd =  $taf. ' TCNamePattern=.*test.*;list'; $rst = `$cmd`; 
	unlike ($rst, qr/\btestcase\b/, $tcDesc.": processTCs TCnamePattern");
	unlike ($rst, qr/\btestcase1\b/, $tcDesc.": processTCs TCnamePattern");
	unlike ($rst, qr/\btestcase2\b/, $tcDesc.": processTCs TCnamePattern");
	unlike ($rst, qr/\btestcase3\b/, $tcDesc.": processTCs TCnamePattern");
	unlike ($rst, qr/\btestcase4\b/, $tcDesc.": processTCs TCnamePattern");
	unlike ($rst, qr/\btestcase_1\b/, $tcDesc.": processTCs TCnamePattern");
	unlike ($rst, qr/\btestcase_2\b/, $tcDesc.": processTCs TCnamePattern");
	unlike ($rst, qr/\btestcase_3\b/, $tcDesc.": processTCs TCnamePattern");
	unlike ($rst, qr/\btestcase_4\b/, $tcDesc.": processTCs TCnamePattern");
	}

__END__

todo: creatTC with overrite 
Test Item: 

	s:
                Drive=c:;
		TestSuite 			- Done
                TCOp=list;
                TCName=TC_tcA1;
			# _testName 1
			_testSuit 1
			#_testSuit\testSuite2
			_testName\testName2
                TCNameFilter=.*; 		- Done
                TCNameExecFilter=.*;
                PropNameFilter=.*;
			#_propName[1-4]{0,}
			_propName
			_propName1
			_propName2
			_propName3
			_propName4
			#_propName_[1-4]
			_propName_1
			_propName_2
			_propName_3
			_propName_4
			#_propName_[1|2|3]
			#_propName\s[1-4]
			_propName 1
			_propName 2
			_propName 3
			_propName 4
			#_propName\propCasee2
			_propName\propCasee2
                PropValueFilter.=.*;
			#_testCase[1-4]{0,}
			_testCase
			_testCase1
			_testCase2
			_testCase3
			_testCase4
			#_testCase_[1-4]
			_testCase_1
			_testCase_2
			_testCase_3
			_testCase_4
			#_testCase_[1|2|3]
			#_testCase\s[1-4]
			_testCase 1
			_testCase 2
			_testCase 3
			_testCase 4
			#_testCase\testCasee2
			_testCase\testCasee2
                pr2Screen=0|1;
                getVars|listVars|printVars

	TC:
                create|list|get|exec|execAll|detect|delete|log|getLogName|reportTCResult|reportResultHistory

	Prop:
                add|delete|list|get|modify|match|filter|create


TestSuite/TCName 
	_testSuit[1-4]{0,}
	_testSuit_[1-4]
	_testSuit_[1|2|3]
	_testSuit\s[1-4]
	_testSuit[1-4]_testSuite[1-4]
RegExp:
	.*
	[]?
	[][1-2]
	[|][1-2]
	\s
	\S


	\b \B
	^
       	$
	a|b|c|
	a{5}
	a{0,}
	a{0,1}
	a+?

	$1, $2


__END__

AutomationFramework Test Cases

TAF defaults:
	get|list
	set

TestOP TC:
create one automated functional test
create one automated perform test
get|list|detect automated test[s]
delete automated test[s]
delete automated test[s]  	N/A
exec automated test[s]


PropertyOp TC 1: 
search|detect a property
create|add a property
create|add default properties
dele a property
dele all properties
modify property
get|list|search|detect properties
get|list|search|detect default properties





