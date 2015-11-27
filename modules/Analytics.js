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
   * isNewUser: Bool
   */
  static async userDidLogin(userId, isNewUser) {
    return TSAnalytics.userDidLogin(userId, isNewUser);
  }

  static async userDidLogout() {
    return TSAnalytics.userDidLogout(); 
  }

  /**
   * username: String
   */
  static async setUserUsername(username) {
    return TSAnalytics.setUserUsername(username);
  }

  /**
   * phone: String
   */
  static async setUserPhone(phone) {
    return TSAnalytics.setUserPhone(phone)
  }

  /**
   * email: String
   */
  static async setUserEmail(email) {
    return TSAnalytics.setUserEmail(email);
  }

  /**
   * fullname: String
   */
  static async setUserFullname(fullname) {
     return TSAnalytics.setUserFullname(fullname);
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
   * properties: {}}
   */
  static async screen(name, properties) {
    return TSAnalytics.screen(name, properties);
  }
}

module.exports = Analytics;