({
    doInit: function(cmp) {
        var action = cmp.get("c.getContactsBasedOnCandidateCriteria");
        action.setParams({ Location : cmp.get("v.locationVal"),
                          Discipline : cmp.get("v.disciplineVal"),
                          Specialty : cmp.get("v.specialtyVal")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("From server: " + JSON.stringify(response.getReturnValue()));
                cmp.set("v.data",result.ResponseWrapperlist);
                cmp.set("v.disciplinelist",result.disciplineList);
                cmp.set("v.locationList",result.locationList);
                cmp.set("v.specialtyList",result.specialtylist);
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})