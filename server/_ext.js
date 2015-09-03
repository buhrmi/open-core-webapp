LivePg.prototype._initListener = function() {
  var self = this;
  pg.connect(self.connStr, function(error, client, done) {
    if(error) return self.emit('error', error);

    self.notifyClient = client;
    self.notifyDone = done;

    client.query('LISTEN "' + self.channel + '"', function(error, result) {
      if(error) return self.emit('error', error);
    });

    client.on('notification', function(info) {
      if(info.channel === self.channel) {
        var payload = self._processNotification(info.payload);

        // Only continue if full notification has arrived
        if(payload === null) return;

        try {
          var payload = JSON.parse(payload);
        } catch(error) {
          return self.emit('error',
            new Error('INVALID_NOTIFICATION ' + payload));
        }

        if(payload.table in self.allTablesUsed) {
          self.allTablesUsed[payload.table].forEach(function(queryHash) {
            var queryBuffer = self.selectBuffer[queryHash];
            if((queryBuffer.triggers
                // Check for true response from manual trigger
                && payload.table in queryBuffer.triggers
                && (payload.op === 'UPDATE'
                  // Rows changed in an UPDATE operation must check old and new
                  ? queryBuffer.triggers[payload.table](payload.new_data[0], 'UPDATE1')
                    || queryBuffer.triggers[payload.table](payload.old_data[0], 'UPDATE2')
                  // Rows changed in INSERT/DELETE operations only check once
                  : queryBuffer.triggers[payload.table](payload.data[0], payload.op)))
              || (queryBuffer.triggers
                // No manual trigger for this table, always refresh
                && !(payload.table in  queryBuffer.triggers))
              // No manual triggers at all, always refresh
              || !queryBuffer.triggers) {

              self.waitingToUpdate.push(queryHash);
            }
          });
        }
      }
    })
  });
}