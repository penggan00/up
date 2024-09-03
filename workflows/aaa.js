addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const content = `文本内容`;

  return new Response(content, {
    headers: {
      'Content-Type': 'text/plain;charset=UTF-8'
    }
  })
}
