const admin = require('../config/firebase'); // Firebase initialization config
const NotificationService = {

    /**

     * Firebase topic par push notification bhejta hai

     * @param {string} topic

     * @param {string} title 
     * @param {string} body 

     * @param {object} extraData 

     */

    sendTopicNotification: async (topic, title, body, extraData = {}) => {

        try {

            const message = {

                notification: {

                    title: title,

                    body: body

                },

                android: {

                    notification: {

                        sound: 'default',

                        clickAction: 'FLUTTER_NOTIFICATION_CLICK',

                    },

                    priority: 'high'

                },

                data: extraData,

                topic: topic

            };



            const response = await admin.messaging().send(message);

            console.log(`[Firebase] Push Notification successfully sent to topic [${topic}]:`, response);

            return response;

        } catch (error) {

            console.error('[Firebase Error] Failed to send push notification:', error.message);

            throw error;

        }

    }

};



module.exports = NotificationService;