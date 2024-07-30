addEventListener('scheduled', event => {
  event.waitUntil(handleScheduled(event));
});

async function handleScheduled(event) {
  const url = 'https://epg.112114.xyz/pp.xml';
  
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    const content = await response.text();
    
    // Store the content in KV storage
    await EPG_STORAGE.put('pp.xml', content);

    console.log('File updated successfully');
  } catch (error) {
    console.error('Failed to update file:', error);
  }
}

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  const content = await EPG_STORAGE.get('pp.xml');
  return new Response(content, {
    headers: { 'Content-Type': 'application/xml' },
  });
}
