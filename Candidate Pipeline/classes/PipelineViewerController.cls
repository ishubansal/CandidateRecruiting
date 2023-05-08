/*
@Author : Ishu
@CreatedDate : 8th May 2023
@Description : PipelineViewerController Class
*/
public class PipelineViewerController {
    
    @AuraEnabled
    public static ResponseWrapperWithPickList getContactsBasedOnCandidateCriteria(String Location,String Discipline,String Specialty){
        
        String Query = 'Select Name,Specialty__c,Discipline__c,Client__c,No_of_pipelined_candidatess__c from Candidate_Criteria__c ';
        boolean UseWhere = false;
        if(Location!='All' && Location!=null){
            Query+= ' Where Client__c=\''+Location+'\'';
            UseWhere = true;
        }
        if(Discipline!='All' && Discipline!=null){
            if(UseWhere){
                Query+= ' AND Discipline__c=\''+Discipline+'\'';
            }else{
                Query+= ' Where Discipline__c=\''+Discipline+'\'';
                UseWhere = true;
            }
        }
        if(Specialty!='All' && Specialty!=null){
            if(UseWhere){
                Query+= ' AND Specialty__c=\''+Specialty+'\'';
            }else{
                Query+= ' Where Specialty__c=\''+Specialty+'\'';
            }
            
        }
        system.debug('Query'+Query);
        list<Candidate_Criteria__c> NameVsCC = Database.query(Query);
        Set<String> allLocations = new Set<String>();
        Set<String> allDisciplines = new Set<String>();
        Set<String> allSpecialties = new Set<String>();
        Map<String,ResponseWrapper> uniqueKeyVsRW = new Map<String,ResponseWrapper>();
        
        for(Candidate_Criteria__c cc : NameVsCC){
            List<Map<String,String>> steps = new List<Map<String,String>>();
            ResponseWrapper res = new ResponseWrapper(cc, new List<Contact>(),steps);
            uniqueKeyVsRW.put(cc.Client__c + '_' + cc.Discipline__c + '_' + cc.Specialty__c,res);
            allLocations.add(cc.Client__c);
            allDisciplines.add(cc.Discipline__c);
            allSpecialties.add(cc.Specialty__c ); 
        }
        
        List<Contact> allContacts = [Select id,Name,Primary_Specialty__c,Discipline__c,Pipeline_Location__c  from Contact where RecordType.Name = 'Candidate' AND Pipeline_Location__c IN:allLocations AND Primary_Specialty__c IN:allSpecialties AND Discipline__c IN:allDisciplines AND AVTRRT__Candidate_Status__c='In Progress'];
        Map<String,List<Contact>> UniqueKeyVsContacts = new Map<String,List<Contact>>();
        for(Contact con:allContacts){
            String uniqueKey = con.Pipeline_Location__c + '_' + con.Discipline__c + '_' + con.Primary_Specialty__c;
            if(uniqueKeyVsRW.containskey(uniqueKey)){
                uniqueKeyVsRW.get(uniqueKey).lcon.add(con);
                uniqueKeyVsRW.get(uniqueKey).steps.add(new Map<String,String>{'Label' => con.Name, 'Value' => con.Id});
            }
        }
        for(Candidate_Criteria__c cc : NameVsCC){
            ResponseWrapper res = uniqueKeyVsRW.get(cc.Client__c + '_' + cc.Discipline__c + '_' + cc.Specialty__c);
            for(Integer i=1;i<=cc.No_of_pipelined_candidatess__c - res.lcon.size();i++){
                res.steps.add(new Map<String,String>{'Label' => '', 'Value' => ''});
            }
        }
        return new ResponseWrapperWithPickList(uniqueKeyVsRW.values(),allLocations,allDisciplines,allSpecialties);
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public Candidate_Criteria__c cc{get;set;}
        @AuraEnabled
        public List<Contact> lcon{get;set;}
        @AuraEnabled
        public List<Map<String,String>> steps{get;set;}
        
        public ResponseWrapper(Candidate_Criteria__c cc,List<Contact> lcon,List<Map<String,String>> steps){
            this.cc = cc;
            this.lcon = lcon;
            this.steps = steps;
        }
    } 
    
    public class ResponseWrapperWithPickList{
        @AuraEnabled
        public list<ResponseWrapper> ResponseWrapperlist{get;set;}
        @AuraEnabled
        public set<String> locationList{get;set;}
        @AuraEnabled
        public set<String> disciplineList{get;set;}
        @AuraEnabled
        public set<String> specialtylist{get;set;}
        
        public ResponseWrapperWithPickList(list<ResponseWrapper> ResponseWrapperlist, set<String> locationList, set<String> disciplineList,set<String> specialtylist){
            this.ResponseWrapperlist = new list<ResponseWrapper>();
            this.ResponseWrapperlist.addAll(ResponseWrapperlist);
            this.locationList = new set<String>();
            this.locationList.addAll(locationList);
            this.disciplineList = new set<String>();
            this.disciplineList.addAll(disciplineList);
            this.specialtylist = new set<String>();
            this.specialtylist.addAll(specialtylist);
        }
    }
    
}