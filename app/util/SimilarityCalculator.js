
/**
 * Given 2 users, calculates an ordered list of similarities for what to display inside the
 * "What you have in common" section.
 */
class SimilarityCalculator {

  _sameTags(forUserTags, userTags) {
    if (!!forUserTags && !!userTags && forUserTags.length > 0 && userTags.length > 0) {
      const userTagTexts = userTags.map(tag => tag.text);
      const sameTags = [];

      forUserTags.forEach(tag => {
        if (userTagTexts.indexOf(tag.text) >= 0) {
          sameTags.push(tag)
        }
      })

      const forUserTagTexts = forUserTags.map(tag => tag.text);
      const otherTags = [];
      userTags.forEach(tag => {
        if (forUserTagTexts.indexOf(tag.text) < 0) {
          otherTags.push(tag)
        }
      })

      return  { same: { tags: sameTags }, other: { tags: otherTags }}
    }

    return { same: { tags: [] }, other: { tags: [] } };
  }

  _sameCourses(forUserCourses, userCourses) {
    if (!!forUserCourses && !!userCourses && forUserCourses.length > 0 && userCourses.length > 0) {
      const userCourseId = userCourses.map(course => course._id);
      const sameCourses = [];
      forUserCourses.forEach(course => {
        if (userCourseId.indexOf(course._id) >= 0) {
          sameCourses.push(course)
        }
      })

      const forUserCourseId = forUserCourses.map(course => course._id)
      const otherCourses = [];
      userCourses.forEach(course => {
        if (forUserCourseId.indexOf(course._id) < 0) {
          otherCourses.push(course)
        }
      })

      return { same: { courses: sameCourses }, other: { courses: otherCourses }}
    }

    return { same: { courses: [] }, other: { courses: [] } };
  }

  /**
   * @return: {
   *  {
   *    same: { courses: [String], tags: [String] },
   *    other: { courses: [String], tags: [String] },
   *  }
   */
  calculate(forUser, toUser) {
    const defaultSimilarity = {
      same:  { courses: [], tags: [] },
      other:  { courses: [], tags: [] },
    };

    const sameCourses = this._sameCourses(forUser.courses, toUser.courses);
    const sameTags = this._sameTags(forUser.tags, toUser.tags);

    return {
      same: Object.assign({}, defaultSimilarity.same, sameCourses.same, sameTags.same),
      other: Object.assign({}, defaultSimilarity.other, sameCourses.other, sameTags.other),
    }
  }
}

module.exports = SimilarityCalculator;
