module.exports.handler = async (event) => {
  console.log('Event: ', event);

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/plain',
    },
    body: `ECHO: ${event.body}`,
  }
}