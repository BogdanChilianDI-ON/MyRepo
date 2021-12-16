console.log('Loading the Calc function');
const {atan2, chain, derivative, e, evaluate, log, pi, pow, round, sqrt} = require('mathjs');

exports.handler = function(event, context, callback) {
    console.log('Received event:', JSON.stringify(event, null, 2));
    if (event.input === undefined) {
        callback("400 Invalid Input");
    }

    let res = {};
    let buff = new Buffer(event.input, 'base64');
    res.input = buff.toString('ascii');
    console.log(res);

    try {
        res.result = evaluate(res.input);
        res.error=false
        res.message = "it worked!";
        if(isNaN(res.result)) {
            res.error = true;
            res.message = "Not a number!";
        }
    }
    catch (e) {
        res.error = true;
        res.result = 0;
        res.message = String(e);
    }
    console.log(res);
    callback(null, res);
};