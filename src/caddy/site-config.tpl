${SCHEME}${PUBLIC_HOSTNAME} {
	reverse_proxy http://${INTERNAL_HOSTNAME} {
		# Extended timeouts
		transport http {
			read_timeout 300s
			write_timeout 300s
			dial_timeout 60s
			versions 1.1 2
		}

		
		# Forwarding headers for upstream (standard proxy headers)
		header_up Host ${HOST_HEADER}

		# WebSocket support - preserve original Connection and Upgrade headers
		header_up Connection {>Connection}
		header_up Upgrade {>Upgrade}

		# Retry on errors (matching nginx proxy_next_upstream)
		fail_duration 1s
		max_fails 3
		unhealthy_status 502 503 504
		unhealthy_latency 10s
		health_uri /
		health_interval 2s
		health_timeout 3s
	}

	# Error handling (matching nginx @maintenance location)
	handle_errors {
		@error {
			expression {http.error.status_code} >= 502 && {http.error.status_code} <= 504
		}
		handle @error {
			respond `{"error": "Service temporarily unavailable"}` {http.error.status_code}
			header Content-Type "application/json"
		}
	}

	# Security headers (matching nginx add_header directives)
	header {
		X-Frame-Options "SAMEORIGIN"
		X-Content-Type-Options "nosniff"
		X-XSS-Protection "1; mode=block"
		Referrer-Policy "strict-origin-when-cross-origin"
	}

	# Gzip compression (matching nginx gzip settings)
	encode gzip {
		minimum_length 1000
	}

	# Logging
	log {
		output stdout
		format console
	}
}

