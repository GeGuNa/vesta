App.Pages.init = function(){
    App.Ajax.request('MAIN.getInitial', {}, function(reply){
        App.Env.initialParams = reply.data;
        //App.Helpers.updateInitial();
    });
        
    App.Pages.prepareHTML();
    
    $('.section.active').removeClass('active');
    $('#'+App.Env.world).addClass('active');
}

App.Pages.prepareHTML = function()
{
    if ('undefined' != typeof App.Pages[App.Env.world].prepareHTML) {
        App.Pages.prepareHTML();
    }  
    else {        
        App.Model[App.Env.world].loadList();
    }
}

App.Pages.DNS.showSubform = function(ref) 
{
    App.Helpers.showLoading();
    var data = ref.find('.source:first').val();
    App.Ajax.request('DNS.getListRecords', {
        spell: data
    }, function(reply) {
        var tpl = App.Templates.get('SUBFORM', 'dns');
        var tpl_records = App.HTML.Build.dns_records(reply.data);
        tpl.set(':SUBRECORDS', tpl_records);
        
        $(ref).find('.show-records').addClass('hidden');
        $(ref).after(tpl.finalize());
        App.Helpers.updateScreen();
    });
}

App.Pages.DNS.edit = function(elm) {
    var options = elm.find('.source').val();
    fb.warn(elm);
    fb.warn(options);
    var tpl = App.HTML.Build.dns_form(options);
    elm.replaceWith(tpl);
}

/*



//
//  DNS


App.Pages.DNS.saveForm = function(evt, params){
    var elm = $(evt.target);
    elm = elm.parents('.b-new-entry');
    
    if (elm.attr('id') == App.Constants.DNS_FORM_ID) {
        var values = App.Helpers.getFormValues(elm);
        if(App.Validate.dnsForm(values)) {
            App.Model.DNS.update(values, source);
            var tpl = App.HTML.Build.dns_entry(values);
            $('#' + App.Constants.DNS_FORM_ID).replaceWith(tpl);
        }
    }
    else {
        var source = $(elm).find('.source').val();
        var values = App.Helpers.getFormValues(elm);
        if(App.Validate.dnsForm(values)) {
            App.Model.DNS.update(values, source);
            var tpl = App.HTML.Build.dns_entry(values);
            elm.replaceWith(tpl);
        }
    }
    App.Helpers.updateScreen();
}

// 
//  IP
App.Pages.IP.prepareHTML = function(){
    App.Model.IP.loadList();
}

App.Pages.IP.saveForm = function(evt, params){
    var elm = $(evt.target);
    elm = elm.parents('.b-new-entry');
    
    if (elm.attr('id') == App.Constants.IP_FORM_ID) {
        var values = App.Helpers.getFormValues(elm);
        if(App.Validate.ipForm(values)) {
            App.Model.IP.update(values, source);
            var tpl = App.HTML.Build.ip_entry(values);
            $('#' + App.Constants.IP_FORM_ID).replaceWith(tpl);
        }
    }
    else {
        var source = $(elm).find('.source').val();
        var values = App.Helpers.getFormValues(elm);
        if(App.Validate.ipForm(values)) {
            App.Model.IP.update(values, source);
            var tpl = App.HTML.Build.ip_entry(values);
            elm.replaceWith(tpl);
        }
    }
    App.Helpers.updateScreen();
}
*/

/*
App.Pages.IP.edit = function(elm) {
    var options = elm.find('.source').val();
    fb.warn(elm);
    fb.warn(options);
    var tpl = App.HTML.Build.ip_form(options);
    elm.replaceWith(tpl);
}

App.Pages.IP.ipNotSaved = function(reply) {
    return App.Helpers.alert(reply.message);
}

App.Pages.IP.remove = function(evt) {
    var confirmed = confirm('Are you sure?');
    if (!confirmed) {
        return;
    }
    var elm = $(evt.target);
    elm.parents('.ip-details-row');
    var values = elm.find('.source').val();
    App.Model.IP.remove(values, elm);
}
*/
