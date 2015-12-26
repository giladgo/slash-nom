FROM ruby:2.2.4-onbuild
WORKDIR /usr/src/app
EXPOSE 31385
ENV RACK_ENV production
CMD ["ruby", "app.rb", "-p", "31385"]
