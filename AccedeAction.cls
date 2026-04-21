public without sharing class AccedeAction {

    @AuraEnabled
    public static void ChangeProductToISA(String applicationId) {

        String newProduct = 'Accede ISA';

        //Selecciona los campos de Application
        Application__c appItem = [SELECT Id, Name, OriginationProcess__c, LendingProduct__c, ApplicationStatusName__c 
        FROM Application__c WHERE Id =: applicationId LIMIT 1];

        //GET Lending Product Accede ISA Id
        String lendingProductId = [SELECT Id, Name FROM LendingProduct__c WHERE Name =: newProduct LIMIT 1][0].Id;

        //GET OriginationProcess Accede ISA Id
        String originationProcessId = [SELECT Id, Name FROM OriginationProcess__c WHERE Name =: newProduct LIMIT 1][0].Id;

        //GET DocumentRules de Accede ISA
        List<DocumentRule__c> documentRulesList = [SELECT  Id, Name, DocumentName__r.NameES__c, Role__c 
        FROM DocumentRule__c WHERE LendingProduct__r.Name =: newProduct];

        //GET MAP DocumentRules Accede ISA Student y Cosigner
        Map<String, Id> mapDocRuleStudent = new Map<String, Id>();
        Map<String, Id> mapDocRuleCosigner = new Map<String, Id>();
        for(DocumentRule__c documentRuleItem : documentRulesList){
            if(documentRuleItem.Role__c == 'Student'){
                mapDocRuleStudent.put(documentRuleItem.DocumentName__r.NameES__c, documentRuleItem.Id);
            }
            if(documentRuleItem.Role__c == 'Co-signer'){
                mapDocRuleCosigner.put(documentRuleItem.DocumentName__r.NameES__c, documentRuleItem.Id);
            }
        }

        //Selecciona y Actualiza DocumentRules en Documents
        List<Document__c> documentList = [SELECT Id, DocumentRule__c, DocumentRule__r.DocumentName__r.NameES__c, DocumentRule__r.Role__c 
        FROM Document__c WHERE Application__c =: applicationId];
        for(Document__c documentItem : documentList){
            if(documentItem.DocumentRule__r.Role__c == 'Student'){
                documentItem.DocumentRule__c = mapDocRuleStudent.get(documentItem.DocumentRule__r.DocumentName__r.NameES__c);
            }
            if(documentItem.DocumentRule__r.Role__c == 'Co-signer'){
                documentItem.DocumentRule__c = mapDocRuleCosigner.get(documentItem.DocumentRule__r.DocumentName__r.NameES__c);
            }
        }
        update documentList;

        //GET MAP ApplicationStatus
        Map<String, Id> mapAppStatus = new Map<String, Id>();
        List<ApplicationStatus__c> appStatusList = [SELECT Id, Name FROM ApplicationStatus__c WHERE OriginationProcess__r.Name =: newProduct];
        for(ApplicationStatus__c appStatusItem : appStatusList){
            mapAppStatus.put(appStatusItem.Name, appStatusItem.Id);
        }

        //Setea y Actualiza Application
        appItem.LendingProduct__c = lendingProductId;
        appItem.OriginationProcess__c = originationProcessId;
        appItem.ApplicationStatus__c = mapAppStatus.get(appItem.ApplicationStatusName__c);
        update appItem;

    
    }

}