// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var slackScraper;

slackScraper = (function() {
  function slackScraper() {
    console.log("\n\nconstructor")
    this.messages = [];
  }

  slackScraper.prototype.getChannelMessages = function() {
    $(".unread", "#channels").each((function(_this){ 
      return function(i, el){
        var channel = $('a', el).data('channel-id')
        if(!_.findWhere(_this.messages, {channel_id: channel})){
          _this.messages.push({
            channel_id: channel,
            count: 1
          })
        } // if
      }
    })(this));
  };
  
  slackScraper.prototype.getDirectMessages = function() {
    $(".unread", "#direct_messages").each((function(_this){
      return function(i, el){ 
        var channel = $('a', el).data('member-id')
        if(!_.findWhere(_this.messages, {channel_id: channel})){
          _this.messages.push({
            channel_id: channel, 
            count: parseInt($(".unread_highlight", el).html(), 10)
          })
        }// if
      }
    })(this));
  };
  
  slackScraper.prototype.saveMessages = function() {
    chrome.fileSystem.getWritableEntry(chosenFileEntry, function(writableFileEntry) {
      writableFileEntry.createWriter(function(writer) {
        writer.onerror = errorHandler;
        writer.onwriteend = callback;

        chosenFileEntry.file(function(file) {
          writer.write(file);
        });
      }, errorHandler);
    });
  }
  
  slackScraper.prototype.printMessages = function() {
    console.log(this.messages);
    return this.messages;
  }

  return slackScraper;

})();


var s = new slackScraper();

$("#channels").bind('DOMSubtreeModified', function () {
  s.getChannelMessages();
  s.printMessages();
  s.saveMessages();
});

$("#direct_messages").bind('DOMSubtreeModified', function () {
  s.getDirectMessages();
  s.printMessages();
});