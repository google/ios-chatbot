const ApiAiAssistant = require('actions-on-google').ApiAiAssistant;
function parade(assistant) {
  assistant.tell(`Chinese New Year Parade in Chinatown from 6pm to 9pm.`);
}
exports.parades = function(request, response) {
    var assistant = new ApiAiAssistant({request: request, response: response});
    var actionMap = new Map();
    actionMap.set("inquiry.parades", parade);
    assistant.handleRequest(actionMap);
};