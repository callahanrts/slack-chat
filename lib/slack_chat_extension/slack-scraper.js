// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var slackScraper;

slackScraper = (function() {
  function slackScraper() {
    this.messages = [];
  }

  slackScraper.prototype.getChannelMessages = function() {
    this.messages = [];
    $(".unread", "#channels").each((function(_this){ 
      return function(i, el){
        var channel = $('a', el).data('channel-id')
        _this.messages.push({
          channel_id: channel,
          count: 1
        })
      }
    })(this));
  };
  
  slackScraper.prototype.getDirectMessages = function() {
    this.messages = [];
    $(".unread", "#direct_messages").each((function(_this){
      return function(i, el){ 
        var channel = $('a', el).data('member-id');
        var count = $(".unread_highlight_" + channel).text();
        _this.messages.push({
          channel_id: channel, 
          count: count
        })
      }
    })(this));
  };
  
  slackScraper.prototype.saveMessages = function() {
    if(this.messages.length > 0){
      $.post('http://localhost:51932/new', {messages: this.messages})
       .done((function(_this){
         return function(data){
          //  _this.messages.length = 0;
         }
      })(this));
    }
  }
  
  return slackScraper;

})();


$("body").prepend("<style>.slackchat { height: 20px; width: 100%; background-color: #000; color: #ccc; z-index: 999; text-align: center; }</style>");
$("body").prepend("<div class='slackchat'>Slack Chat is running</div>");

var s = new slackScraper();

$("#channels").bind('DOMSubtreeModified', function () {
  s.getChannelMessages();
  s.saveMessages();
});

$("#direct_messages").bind('DOMSubtreeModified', function () {
  s.getDirectMessages();
  s.saveMessages();
});