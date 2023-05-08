/*
@Author : Ishu
@CreatedDate : 8th May 2023
@Description : TestPipelineViewerController test Class
*/
@isTest
public class TestPipelineViewerController {
    
    public static testMethod void test1(){
        
        AVTRRT__Config_Settings__c cs = new AVTRRT__Config_Settings__c();
        cs.Name = 'Default';
        cs.Enable_UpdateSpeciality_on_Contact__c=True;
        insert cs;
        
        Candidate_Criteria__c candidate = new Candidate_Criteria__c();
        candidate.Name = 'CC-0001';
        candidate.Client__c = 'Boston Medical Center';
        candidate.Discipline__c = 'Registered Nurse (RN)';
        candidate.Specialty__c = 'Medical Surgical';
        candidate.No_of_pipelined_candidatess__c = 3;
        insert candidate;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.Primary_Specialty__c= 'Medical Surgical';
        con.Discipline__c='Registered Nurse (RN)';
        con.Pipeline_Location__c='Boston Medical Center';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        con.AVTRRT__Candidate_Status__c='In Progress';
        insert con;
        
        PipelineViewerController.getContactsBasedOnCandidateCriteria('Boston Medical Center','Registered Nurse (RN)','Medical Surgical'); 
    }   
}