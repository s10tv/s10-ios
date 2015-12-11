jest.dontMock('../SimilarityCalculator');
let SimilarityCalculator = require("../SimilarityCalculator");

function createUser(name, courseCodes, tags) {
  return {
    _id: name,
    firstName: name,
    courses: courseCodes.map((code) => { return { _id: code, courseCode: code} }),
    tags: tags,
  }
}

describe('SimilarityCalculator', () => {

  let handler;

  let qiming;
  let nurym;
  let tony;

  beforeEach(() => {
    handler = new SimilarityCalculator()
  })

  beforeEach(() => {
    qiming = createUser('qiming', ['econ101', 'psyc101'], [{ text:'food', type: 'food' }])

    // tony shares classes and tags with qiming
    tony = createUser('tony', ['econ101'], [{ text:'food', type: 'food' }])

    // nurym shares nothing with qiming
    nurym = createUser('nurym', ['cs101'], [{ text: 'purpledrank', type: 'party' }])
  })

  describe('users with common attributes', () => {
    it('should return similar courses and tags', () => {
      const result = handler.calculate(qiming, tony);
      expect(result.same.courses[0]._id).toEqual('econ101');
      expect(result.same.tags[0].text).toEqual('food');

      expect(result.other.courses.length).toEqual(0)
      expect(result.other.tags.length).toEqual(0)
    })
  })

  describe('users with nothing in common', () => {
    it ('should return courses and tags from the user in a separate section', () => {
      const result = handler.calculate(qiming, nurym);
      expect(result.same.courses.length).toEqual(0)
      expect(result.same.tags.length).toEqual(0)

      expect(result.other.courses[0]._id).toEqual('cs101');
      expect(result.other.tags[0].text).toEqual('purpledrank');
    })
  })
})
