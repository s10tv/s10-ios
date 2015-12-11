export function formatCourse(dept, course) {
  var lowercaseDept = dept.toLowerCase()
  return `${lowercaseDept.charAt(0).toUpperCase() + lowercaseDept.slice(1)} ${course}`
}
