/**
 * @flow
 */
'use strict';

const React = require('react-native');
const {
  NativeModules: {
    TSAnalytics,
  },
} = React;


class Analytics {
  /**
   * userId: String
   */
  static async identify(userId) {
    return TSAnalytics.identify(userId);
  }

  /**
   * event: String
   * properties: {}
   */
  static async track(event, properties) {
    return TSAnalytics.track(event, properties);
  }

  /**
   * name: String
   * value: String
   */
  static async setUserProperty(name, value) {
    return TSAnalytics.track(name, value);
  }

  /**
   * name: String
   * amount: number
   */
  static async incrementUserProperty(name, amount) {
    return TSAnalytics.incrementUserProperty(name, amount);
  }
}

module.exports = Analytics;