function save_draft(msg_id, user_id){
    var form = document.getElementById('compose');
    if('new' == msg_id){
        form.action = "/users/"+ user_id +"/messages/";
    }
    else{
        form.action = "/users/"+ user_id +"/messages/"+ msg_id;
        form.elements._method.value = 'put';
    }
    form.submit();
}
function send_request(form, action){
    new Ajax.Request( action,
    {
        method: 'post',
        parameters: Form.serialize(form.id),
        asynchronous: true,
        evalScripts: true
    });
}
function set_email(arg){
    val = document.getElementById('recepient_id').value;
    if(val == '')
        document.getElementById('recepient_id').value = arg;
    else
        document.getElementById('recepient_id').value = val + ',' + arg;
}
function select_deselect_all(domElement){
    var i = 0, allElements=domElement.form, j = 1;
    for(i=0; i<allElements.length; i++)
    {
        if (allElements[i].type=='checkbox')
            if(true == $('select_all').checked)
                allElements[i].checked=1;
            else
                allElements[i].checked=0;
    }
}
function setMessage_body(val){
    // Get the editor instance that we want to interact with.
//    var oEditor = FCKeditorAPI.GetInstance( 'message__message_editor' );
    // Set the editor contents.
//    oEditor.SetHTML( val ) ;
}
function set_email_as_group(val, user_id) {
    new Ajax.Request( "/user/"+ user_id + "/get_email_id",
    {
        method: 'get',
        parameters: {
            ids :val
        },
        asynchronous: true,
        evalScripts: true,
        onSuccess: function(response){
            var str =  response.responseText;
            str.toString();
            var current_vals  = document.getElementById('recepient_id').value;
            if('' == current_vals)
                document.getElementById('recepient_id').value = str;
            else
                document.getElementById('recepient_id').value = current_vals + ',' + str;
        }
    });
}
function bulk_operation(form){
    
    var i=0, allElements=document.getElementById(form).elements;
    for(i=0; i<allElements.length; i++) {
        if (allElements[i].type=='checkbox') {
            if(allElements[i].id == "select_all") continue;
            if(allElements[i].checked==true) {
                return true;
            }
        }
    }
    alert('Please select atleast one messages');
    return false;
}

function test(){
    alert(document.getElementById('bulk_actions').value);
    alert(document.getElementsByName('conv_ids[]').item(0).checked);
    
    return true
}

function select_messages(value, convChkBoxName){
    var chkbox_collection = document.getElementsByName(convChkBoxName);
    var check;
    if(value == 'All')
        check = true;
    else
        check = false;
    for(var i = 0; i < chkbox_collection.length; i++){
        item = chkbox_collection.item(i);
        item.checked = check;
    }
    return false;
}

function message_selected(convChkBoxName){
    var chkbox_collection = document.getElementsByName(convChkBoxName)
    var checked = new Array();
    var item;
    for(var i = 0; i < chkbox_collection.length; i++){
        item = chkbox_collection.item(i)
        if(item.checked)
            checked.push(item.value);
    }

    if(checked.length == 0)
        return false;
    else
        return true
}

function submit_form_with_options(form_id, action, method){
    var form = document.getElementById(form_id);
    if(method)
        form._method.value = method;
    if(action){
        form.action = action;
        form.submit();
    }
    else
        alert('Invalid form action!');
}

function construct_parameters(selectionValue){
    var ar = selectionValue.split('_');
    return {
        action : ar[0],
        arg : ar[1],
        value : ar[2]
    };
}

function request_bulk_action(formId, actionSelectBoxId, convChkBoxName){
    var action_select_box = document.getElementById(actionSelectBoxId)
    if(message_selected(convChkBoxName)){
        var params = construct_parameters(action_select_box.value);
        var action = 'messages/' + params.action + '?' + params.arg + '=' + params.value;
        submit_form_with_options(formId, action, 'put');
        return true;
    }
    else{
        alert('Please select atleast one message!');
        action_select_box.selectedIndex = 0;
        return false;
    }
}

function request_bulk_delete(formId, action, convChkBoxName, msg){
    if(message_selected(convChkBoxName)){
        if('delete' == action){
            msg = msg || "Are you sure?"
            if(!confirm(msg))
                return false;
        }
        action = 'messages/' + action;
        submit_form_with_options(formId, action, 'delete');
        return true;
    }
    else{
        alert('Please select atleast one message!');
        return false;
    }
}

function request_bulk_restore(formId, convChkBoxName){
    if(message_selected(convChkBoxName)){
        var action = 'messages/restore';
        submit_form_with_options(formId, action, 'put');
        return true;
    }
    else{
        alert('Please select atleast one message!');
        return false;
    }
}

function update_per_page(formID, selectID){
    var selectBox = document.getElementById(selectID);
    var action = "messages/update_per_page?val=" + selectBox.value;
    submit_form_with_options(formID, action, 'put');
//    window.location.href = "messages/refresh?per_page=" + selectBox.value;
//    window.location.reload();
}

function get(url){
    window.location.href = url;
    return false;
}

//function sort_messages(sort_by){
//    window.location.href = 'messages?sort=' + sort_by;
//    return false;
//}