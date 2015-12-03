'use strict';

const React = require('react-native');
const {
  NativeModules: {
    TSAnalytics,
  },
} = React;

class Analytics {

  /**
   * isNewUser: Bool
   */
  static async userDidLogin(isNewUser) {
    return TSAnalytics.userDidLogin(isNewUser);
  }

  static async userDidLogout() {
    return TSAnalytics.userDidLogout();
  }

  static async updateUsername() {
    return TSAnalytics.updateUsername();
  }

  static async updatePhone() {
    return TSAnalytics.updatePhone()
  }

  static async updateEmail() {
    return TSAnalytics.updateEmail();
  }

  static async updateFullname() {
     return TSAnalytics.updateFullname();
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
    // TODO: Screen as it is currently implemented gets called every
    // time a page renders. This could happen once per state change.
    // Too noisy.
    //
    // return TSAnalytics.screen(name, properties);
    return Promise.resolve(true);
  }
}

module.exports = Analytics;
