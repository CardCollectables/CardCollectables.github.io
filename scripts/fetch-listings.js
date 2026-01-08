#!/usr/bin/env node
// scripts/fetch-listings.js
// Fetch live eBay listings using eBay API and write to data/listings.json

const fs = require('fs');
const path = require('path');

async function fetchListings() {
  const appId = process.env.EBAY_APP_ID;
  const token = process.env.EBAY_AUTH_TOKEN;
  const username = process.env.EBAY_USERNAME || 'card-collectables';

  if (!appId || !token) {
    console.error('Error: EBAY_APP_ID and EBAY_AUTH_TOKEN env vars required');
    process.exit(1);
  }

  try {
    // Use eBay Finding API to search for seller's active listings
    const url = 'https://svcs.ebay.com/services/search/FindingService/v1';
    const params = new URLSearchParams({
      'OPERATION-NAME': 'findItemsByMerchant',
      'SECURITY-APPNAME': appId,
      'RESPONSE-DATA-FORMAT': 'JSON',
      'REST-PAYLOAD': 'true',
      'seller-id': username,
      'paginationInput.entriesPerPage': '200',
      'sortOrder': 'EndTimeSoonest' // newest first
    });

    console.log('Fetching listings from eBay for seller:', username);
    const res = await fetch(`${url}?${params}`);
    const data = await res.json();

    const listings = [];
    if (data.findItemsByMerchantResponse?.[0]?.searchResult?.[0]?.item) {
      const items = data.findItemsByMerchantResponse[0].searchResult[0].item;
      
      items.forEach(item => {
        const pubDate = new Date(item.listingInfo?.[0]?.startTime?.[0]);
        listings.push({
          id: item.itemId?.[0],
          title: item.title?.[0]?.substring(0, 100),
          price: item.sellingStatus?.[0]?.currentPrice?.[0]?.__value__ || 'N/A',
          url: item.viewItemURL?.[0],
          listingDate: !isNaN(pubDate) ? pubDate.toISOString() : new Date().toISOString()
        });
      });
    }

    // Sort by listingDate descending (newest first)
    listings.sort((a, b) => new Date(b.listingDate) - new Date(a.listingDate));

    // Write to data/listings.json
    const outDir = path.join(__dirname, '..', 'data');
    if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
    
    const outPath = path.join(outDir, 'listings.json');
    fs.writeFileSync(outPath, JSON.stringify(listings, null, 2));
    console.log(`✓ Wrote ${listings.length} listings to ${outPath}`);

  } catch (e) {
    console.error('Error fetching listings:', e.message);
    process.exit(1);
  }
}

fetchListings();
